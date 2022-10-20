// contracts/OnChainScheduler.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnChainScheduler is ERC721 {
    string private constant _name = "SiwaNFT";
    string private constant _symbol = "SIWA";

    address private aggregator0Address;
    uint256 private aggregatorCounter;
    uint256 private roundRobinCounter;
    address[] private dkgCapacityHeap;
    mapping(address => uint256) private aggregatorIdMap;
    mapping(address => uint256) private aggregatorRankMap;

    constructor() ERC721(_name, _symbol) {}

    event AggregatorAlreadyRegistered(uint256 aggregatorId);
    event AggregatorAlreadyActivated(uint256 aggregatorId);
    event AggregatorActivated(uint256 aggregatorId);
    event AggregatorUnregistered();
    event AggregatorAlreadyDeactivated(uint256 aggregatorId);
    event AggregatorDeactivated(uint256 aggregatorId);
    event AggregatorAssigned(uint256 aggregatorId);
    event DkgCapacityIncreased(uint256 aggregatorId, uint256 dkgCapacity);
    event DkgCapacityDecreased(uint256 aggregatorId, uint256 dkgCapacity);

    function activateAggregator() public returns (uint256) {
        uint256 aggregatorId;
        if (aggregatorRegistered(msg.sender)) {
            aggregatorId = aggregatorIdMap[msg.sender];
            emit AggregatorAlreadyRegistered(aggregatorId);
            if (aggregatorActivated(msg.sender)) {
                emit AggregatorAlreadyActivated(aggregatorId);
                return aggregatorId;
            }
        } else {
            if (aggregatorCounter == 0) {
                aggregator0Address = msg.sender;
            }
            aggregatorId = aggregatorCounter++;
        }
        dkgCapacityHeap.push(msg.sender);
        aggregatorRankMap[msg.sender] = dkgCapacityHeap.length - 1;
        swapElemOfHeap(0, dkgCapacityHeap.length - 1);
        minHeapify(0);
        aggregatorIdMap[msg.sender] = aggregatorId;
        emit AggregatorActivated(aggregatorId);
        return aggregatorId;
    }

    function deactivateAggregator() public {
        if (!aggregatorRegistered(msg.sender)) {
            emit AggregatorUnregistered();
            return;
        }
        uint256 aggregatorId = aggregatorIdMap[msg.sender];
        if (!aggregatorActivated(msg.sender)) {
            emit AggregatorAlreadyDeactivated(aggregatorId);
            return;
        }
        uint256 rank = aggregatorRankMap[msg.sender];
        swapElemOfHeap(rank, dkgCapacityHeap.length - 1);
        swapElemOfHeap(0, rank);
        dkgCapacityHeap.pop();
        minHeapify(0);
        emit AggregatorDeactivated(aggregatorId);
    }

    function assignAggregator() public returns (uint256) {
        uint256 aggregatorId = roundRobinCounter;
        if (dkgCapacityHeap.length == 0) {
            require(aggregatorCounter > 0);
            roundRobinCounter = (roundRobinCounter + 1) % aggregatorCounter;
        } else {
            aggregatorId = aggregatorIdMap[dkgCapacityHeap[0]];
        }
        emit AggregatorAssigned(aggregatorId);
        return aggregatorId;
    }

    function increaseDkgCapacity(uint256 nftId) public {
        require(aggregatorRegistered(msg.sender));
        require(aggregatorActivated(msg.sender));
        uint256 rank = aggregatorRankMap[msg.sender];
        _safeMint(msg.sender, nftId);
        minHeapify(rank);
        emit DkgCapacityIncreased(
            aggregatorIdMap[msg.sender],
            balanceOf(msg.sender)
        );
    }

    function decreaseDkgCapacity(uint256 nftId) public {
        require(aggregatorRegistered(msg.sender));
        require(aggregatorActivated(msg.sender));
        uint256 rank = aggregatorRankMap[msg.sender];
        _burn(nftId);
        swapElemOfHeap(0, rank);
        minHeapify(0);
        emit DkgCapacityDecreased(
            aggregatorIdMap[msg.sender],
            balanceOf(msg.sender)
        );
    }

    function aggregatorRegistered(address aggregatorAddress)
        private
        view
        returns (bool)
    {
        uint256 aggregatorId = aggregatorIdMap[aggregatorAddress];
        if (aggregatorId == 0) {
            return
                aggregator0Address != address(0) &&
                aggregatorAddress == aggregator0Address;
        }
        return true;
    }

    function aggregatorActivated(address aggregatorAddress)
        private
        view
        returns (bool)
    {
        uint256 rank = aggregatorRankMap[aggregatorAddress];
        if (rank >= dkgCapacityHeap.length) {
            return false;
        }
        return aggregatorAddress == dkgCapacityHeap[rank];
    }

    function swapElemOfHeap(uint256 x, uint256 y) private {
        if (x >= dkgCapacityHeap.length || y >= dkgCapacityHeap.length) {
            return;
        }
        address elemAtX = dkgCapacityHeap[x];
        dkgCapacityHeap[x] = dkgCapacityHeap[y];
        dkgCapacityHeap[y] = elemAtX;
        aggregatorRankMap[dkgCapacityHeap[x]] = x;
        aggregatorRankMap[dkgCapacityHeap[y]] = y;
    }

    function minHeapify(uint256 rank) private {
        uint256 leftChild = rank * 2 + 1;
        uint256 rightChild = rank * 2 + 2;
        uint256 nextRank = rank;
        if (
            leftChild < dkgCapacityHeap.length &&
            balanceOf(dkgCapacityHeap[leftChild]) <
            balanceOf(dkgCapacityHeap[nextRank])
        ) {
            nextRank = leftChild;
        }
        if (
            rightChild < dkgCapacityHeap.length &&
            balanceOf(dkgCapacityHeap[rightChild]) <
            balanceOf(dkgCapacityHeap[nextRank])
        ) {
            nextRank = rightChild;
        }
        if (nextRank != rank) {
            swapElemOfHeap(rank, nextRank);
            minHeapify(nextRank);
        }
    }
}
