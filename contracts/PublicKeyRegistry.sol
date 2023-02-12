// contracts/PublicKeyRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./BN256G2.sol";

contract PublicKeyRegistry {
    address private _owner;
    mapping(address => uint256) private _actualNodeToGroup;
    mapping(address => uint256) private _expectedNodeToGroup;
    mapping(uint256 => uint256[4]) private _actualPublicKey;
    mapping(uint256 => uint256[4]) private _expectedPublicKey;

    constructor() public {
        _owner = msg.sender;
    }

    event ActualPublicKeyUpdated(
        uint256 groupId,
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    );

    event ExpectedPublicKeyUpdated(
        uint256 groupId,
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    );

    function getOwner() public view returns (address) {
        return _owner;
    }

    function ifActualPublicKeyEqualtoExpected(uint256 groupId)
        public
        view
        returns (bool)
    {
        return
            _actualPublicKey[groupId][0] == _expectedPublicKey[groupId][0] &&
            _actualPublicKey[groupId][1] == _expectedPublicKey[groupId][1] &&
            _actualPublicKey[groupId][2] == _expectedPublicKey[groupId][2] &&
            _actualPublicKey[groupId][3] == _expectedPublicKey[groupId][3];
    }

    function setActualNodeToGroup(address nodeAddr, uint256 groupId) public {
        require(msg.sender == _owner);
        _actualNodeToGroup[nodeAddr] = groupId;
    }

    function setExpectedNodeToGroup(address nodeAddr, uint256 groupId) public {
        require(msg.sender == _owner);
        _expectedNodeToGroup[nodeAddr] = groupId;
    }

    function setExpectedPublicKeyToActual(uint256 groupId) public {
        require(msg.sender == _owner);
        _expectedPublicKey[groupId] = _actualPublicKey[groupId];
    }

    function updateActualPublicKey(
        uint256 groupId,
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) public {
        require(_actualNodeToGroup[msg.sender] == groupId);
        _actualPublicKey[groupId][0] = xx;
        _actualPublicKey[groupId][1] = xy;
        _actualPublicKey[groupId][2] = yx;
        _actualPublicKey[groupId][3] = yy;
        emit ActualPublicKeyUpdated(
            groupId,
            _actualPublicKey[groupId][0],
            _actualPublicKey[groupId][1],
            _actualPublicKey[groupId][2],
            _actualPublicKey[groupId][3]
        );
    }

    function addToExpectedPublicKey(
        uint256 groupId,
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) public {
        require(_expectedNodeToGroup[msg.sender] == groupId);
        uint256[4] memory result;
        (result[0], result[1], result[2], result[3]) = BN256G2.ecTwistAdd(
            _expectedPublicKey[groupId][0],
            _expectedPublicKey[groupId][1],
            _expectedPublicKey[groupId][2],
            _expectedPublicKey[groupId][3],
            xx,
            xy,
            yx,
            yy
        );
        _expectedPublicKey[groupId] = result;
        emit ExpectedPublicKeyUpdated(
            groupId,
            _expectedPublicKey[groupId][0],
            _expectedPublicKey[groupId][1],
            _expectedPublicKey[groupId][2],
            _expectedPublicKey[groupId][3]
        );
    }
}
