// contracts/OnChainScheduler.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnChainScheduler is ERC721 {
    string private constant _name = "SiwaNFT";
    string private constant _symbol = "SIWA";

    address private aggregator0Address;
    address private contractCreator;
    uint256 private aggregatorCounter;
    uint256 private roundRobinCounter;
    address[] private dkgCapacityHeap;
    mapping(address => uint256) private aggregatorIdMap;
    mapping(address => uint256) private aggregatorRankMap;

    constructor() ERC721(_name, _symbol) {
        contractCreator = msg.sender;
    }

    function registerAggregator() public returns (uint256) {
        require(msg.sender == contractCreator);
        if (aggregatorCounter == 0) {
            aggregator0Address = msg.sender;
        }
        if (aggregatorRankMap[msg.sender] < dkgCapacityHeap.length) {
            // if aggregator is unregistered, aggregatorRankMap[msg.sender] == 0
            require(aggregatorRegistered(msg.sender));
            return aggregatorIdMap[msg.sender];
        }
        uint256 aggregatorId = aggregatorCounter++;
        dkgCapacityHeap.push(msg.sender);
        aggregatorRankMap[msg.sender] = dkgCapacityHeap.length - 1;
        swapElemOfHeap(0, dkgCapacityHeap.length - 1);
        minHeapify(0);
        aggregatorIdMap[msg.sender] = aggregatorId;
        return aggregatorId;
    }

    function deregisterAggregator() public {
        require(msg.sender == contractCreator);
        require(aggregatorRegistered(msg.sender));
        uint256 rank = aggregatorRankMap[msg.sender];
        if (rank >= dkgCapacityHeap.length) {
            return;
        }
        swapElemOfHeap(rank, dkgCapacityHeap.length - 1);
        swapElemOfHeap(0, rank);
        dkgCapacityHeap.pop();
        minHeapify(0);
    }

    function assignAggregator() public returns (uint256) {
        uint256 aggregatorId = roundRobinCounter;
        if (dkgCapacityHeap.length == 0) {
            require(aggregatorCounter > 0);
            roundRobinCounter = (roundRobinCounter + 1) % aggregatorCounter;
        } else {
            aggregatorId = aggregatorIdMap[dkgCapacityHeap[0]];
        }
        return aggregatorId;
    }

    function increaseDkgCapacity(uint256 nftId) public {
        require(aggregatorRegistered(msg.sender));
        uint256 rank = aggregatorRankMap[msg.sender];
        _safeMint(msg.sender, nftId);
        minHeapify(rank);
    }

    function decreaseDkgCapacity(uint256 nftId) public {
        require(aggregatorRegistered(msg.sender));
        uint256 rank = aggregatorRankMap[msg.sender];
        _burn(nftId);
        require(dkgCapacityHeap.length > 0);
        swapElemOfHeap(0, rank);
        minHeapify(0);
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

    function swapElemOfHeap(uint256 x, uint256 y) private {
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
