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
    address[] private dkgCapacityMinHeap;
    mapping(address => uint256) private aggregatorIdMap;
    mapping(uint256 => uint256) aggregatorRankMap;

    constructor() ERC721(_name, _symbol) {
        contractCreator = msg.sender;
    }

    function assignAggregator() public view returns (uint256) {
        uint256 aggregatorId = roundRobinCounter;
        if (dkgCapacityMinHeap.length > 0) {
            aggregatorId = aggregatorIdMap[dkgCapacityMinHeap[0]];
            if (aggregatorId == 0) {
                require(dkgCapacityMinHeap[0] == aggregator0Address);
            }
        }
        return aggregatorId;
    }

    function increaseDkgCapacity(uint256 nftId) public {
        uint256 aggregatorId = getAggregatorIdByAddress(msg.sender);
        uint256 rank = aggregatorRankMap[aggregatorId];
        _safeMint(msg.sender, nftId);
        minHeapify(rank);
    }

    function decreaseDkgCapacity(uint256 nftId) public {
        uint256 aggregatorId = getAggregatorIdByAddress(msg.sender);
        uint256 rank = aggregatorRankMap[aggregatorId];
        _burn(nftId);
        require(dkgCapacityMinHeap.length > 0);
        address rootAggregatorAddress = dkgCapacityMinHeap[0];
        dkgCapacityMinHeap[0] = dkgCapacityMinHeap[rank];
        dkgCapacityMinHeap[rank] = rootAggregatorAddress;
        minHeapify(0);
    }

    function getAggregatorIdByAddress(address aggregatorAddress)
        private
        view
        returns (uint256)
    {
        uint256 aggregatorId = aggregatorIdMap[aggregatorAddress];
        if (aggregatorId == 0) {
            require(
                aggregator0Address != address(0) &&
                    aggregatorAddress == aggregator0Address
            );
        }
        return aggregatorId;
    }

    function minHeapify(uint256 rank) private {
        uint256 leftChild = rank * 2 + 1;
        uint256 rightChild = rank * 2 + 2;
        uint256 nextRank = rank;
        if (
            leftChild < dkgCapacityMinHeap.length &&
            balanceOf(dkgCapacityMinHeap[leftChild]) <
            balanceOf(dkgCapacityMinHeap[nextRank])
        ) {
            nextRank = leftChild;
        }
        if (
            rightChild < dkgCapacityMinHeap.length &&
            balanceOf(dkgCapacityMinHeap[rightChild]) <
            balanceOf(dkgCapacityMinHeap[nextRank])
        ) {
            nextRank = rightChild;
        }
        if (nextRank != rank) {
            address minBalanceAddress = dkgCapacityMinHeap[nextRank];
            dkgCapacityMinHeap[nextRank] = dkgCapacityMinHeap[rank];
            dkgCapacityMinHeap[rank] = minBalanceAddress;
            minHeapify(nextRank);
        }
    }
}
