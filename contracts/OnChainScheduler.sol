// contracts/OnChainScheduler.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract OnChainScheduler {
    address private _owner;
    uint256 private _groupCounter;
    uint256[] private _groupHeap;
    mapping(uint256 => bool) private _groupDeleted;
    mapping(uint256 => uint256) private _groupRankInHeap;
    mapping(uint256 => uint256) private _groupSize;

    constructor() public {
        _owner = msg.sender;
    }

    event GroupNewed(uint256 id);
    event GroupDeletedWithoutTransfer(uint256 id, uint256 size);
    event GroupDeletedWithTransfer(uint256 from, uint256 to, uint256 size);
    event GroupSizeUpdated(uint256 id, uint256 size);

    modifier isValidGroup(uint256 groupId) {
        require(groupId > 0);
        require(groupId <= _groupCounter);
        require(!_groupDeleted[groupId]);
        _;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function assignGroup() public view returns (uint256) {
        require(_groupHeap.length > 0);
        return _groupHeap[0];
    }

    function newGroup() public returns (uint256) {
        require(msg.sender == _owner);
        _groupCounter++;
        _groupHeap.push(_groupCounter);
        _groupRankInHeap[_groupCounter] = _groupHeap.length - 1;
        percolateUp(_groupHeap.length - 1);
        emit GroupNewed(_groupCounter);
        return _groupCounter;
    }

    function deleteGroup(uint256 groupId) public isValidGroup(groupId) {
        require(msg.sender == _owner);
        _groupDeleted[groupId] = true;
        if (_groupHeap.length == 1) {
            _groupHeap.pop();
            emit GroupDeletedWithoutTransfer(groupId, _groupSize[groupId]);
            return;
        }
        uint256 groupRankInHeap = _groupRankInHeap[groupId];
        uint256 transferTo = _groupHeap[0];
        uint256 transferSize = _groupSize[groupId];
        if (groupRankInHeap == 0) {
            uint256 targetRank = 1;
            if (
                _groupHeap.length > 2 &&
                _groupSize[_groupHeap[2]] < _groupSize[_groupHeap[1]]
            ) {
                targetRank = 2;
            }
            transferTo = _groupHeap[targetRank];
            _groupSize[transferTo] += transferSize;
            _groupSize[groupId] = 0;
            percolateDown(targetRank);
            swapInHeap(0, _groupHeap.length - 1);
            _groupHeap.pop();
        } else {
            _groupSize[transferTo] += transferSize;
            _groupSize[groupId] = 0;
            swapInHeap(groupRankInHeap, _groupHeap.length - 1);
            _groupHeap.pop();
            percolateDown(groupRankInHeap);
        }
        percolateDown(0);
        emit GroupDeletedWithTransfer(groupId, transferTo, transferSize);
    }

    function increaseGroupSize(uint256 groupId) public isValidGroup(groupId) {
        require(msg.sender == _owner);
        _groupSize[groupId]++;
        percolateDown(_groupRankInHeap[groupId]);
        emit GroupSizeUpdated(groupId, _groupSize[groupId]);
    }

    function decreaseGroupSize(uint256 groupId) public isValidGroup(groupId) {
        require(msg.sender == _owner);
        if (_groupSize[groupId] == 0) {
            return;
        }
        _groupSize[groupId]--;
        percolateUp(_groupRankInHeap[groupId]);
        emit GroupSizeUpdated(groupId, _groupSize[groupId]);
    }

    function swapInHeap(uint256 rank1, uint256 rank2) private {
        if (rank1 >= _groupHeap.length || rank2 >= _groupHeap.length) {
            return;
        }
        uint256 elem1 = _groupHeap[rank1];
        _groupHeap[rank1] = _groupHeap[rank2];
        _groupHeap[rank2] = elem1;
        _groupRankInHeap[_groupHeap[rank1]] = rank1;
        _groupRankInHeap[_groupHeap[rank2]] = rank2;
    }

    function percolateUp(uint256 rank) private {
        if (rank == 0) {
            return;
        }
        uint256 parent = (rank - 1) / 2;
        if (_groupSize[_groupHeap[parent]] <= _groupSize[_groupHeap[rank]]) {
            return;
        }
        swapInHeap(parent, rank);
        percolateUp(parent);
    }

    function percolateDown(uint256 rank) private {
        uint256 leftChild = rank * 2 + 1;
        uint256 rightChild = rank * 2 + 2;
        uint256 nextRank = rank;
        if (
            leftChild < _groupHeap.length &&
            _groupSize[_groupHeap[leftChild]] < _groupSize[_groupHeap[nextRank]]
        ) {
            nextRank = leftChild;
        }
        if (
            rightChild < _groupHeap.length &&
            _groupSize[_groupHeap[rightChild]] <
            _groupSize[_groupHeap[nextRank]]
        ) {
            nextRank = rightChild;
        }
        if (nextRank == rank) {
            return;
        }
        swapInHeap(rank, nextRank);
        percolateDown(nextRank);
    }
}
