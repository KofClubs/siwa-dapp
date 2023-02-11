// contracts/OffChainScheduler.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract OffChainScheduler {
    address private _owner;
    address private _scheduler;
    uint256 private _ctxId;
    uint256 private _groupCounter;

    constructor() public {
        _owner = msg.sender;
    }

    event AssignGroupRequested(uint256 ctxId);
    event AssignGroupResponded(uint256 ctxId, uint256 groupId);
    event GroupNewed(uint256 id);
    event GroupDeleted(uint256 id);
    event GroupSizeIncreased(uint256 id);
    event GroupSizeDecreased(uint256 id);

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getScheduler() public view returns (address) {
        return _scheduler;
    }

    function setScheduler(address scheduler) public {
        require(msg.sender == _owner);
        _scheduler = scheduler;
    }

    function assignGroup() public {
        require(msg.sender == _owner);
        _ctxId++;
        emit AssignGroupRequested(_ctxId);
    }

    function handleAssignGroup(uint256 ctxId, uint256 groupId) public {
        require(msg.sender == _scheduler);
        emit AssignGroupResponded(ctxId, groupId);
    }

    function newGroup() public {
        require(msg.sender == _owner);
        _groupCounter++;
        emit GroupNewed(_groupCounter);
    }

    function deleteGroup(uint256 groupId) public {
        require(msg.sender == _owner);
        emit GroupDeleted(groupId);
    }

    function increaseGroupSize(uint256 groupId) public {
        require(msg.sender == _owner);
        emit GroupSizeIncreased(groupId);
    }

    function decreaseGroupSize(uint256 groupId) public {
        require(msg.sender == _owner);
        emit GroupSizeDecreased(groupId);
    }
}
