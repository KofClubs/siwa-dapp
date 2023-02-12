// contracts/OnChainAggregator.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract OnChainAggregator {
    address private _owner;
    mapping(address => bool) private _permittedSigner;
    mapping(uint256 => mapping(string => uint256)) private _vote;
    mapping(uint256 => string[]) private _candidate;

    constructor() public {
        _owner = msg.sender;
    }

    function equalString(string storage x, string calldata y)
        internal
        pure
        returns (bool)
    {
        bytes memory xBytes = bytes(x);
        bytes memory yBytes = bytes(y);
        if (xBytes.length != yBytes.length) {
            return false;
        }
        for (uint256 i = 0; i < xBytes.length; i++) {
            if (xBytes[i] != yBytes[i]) {
                return false;
            }
        }
        return true;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getResult(uint256 ctxId) public view returns (string memory) {
        require(msg.sender == _owner);
        uint256 sumOfCVote;
        string memory result;
        uint256 voteOfResult;
        for (uint256 i = 0; i < _candidate[ctxId].length; i++) {
            sumOfCVote += _vote[ctxId][_candidate[ctxId][i]];
            if (_vote[ctxId][_candidate[ctxId][i]] > voteOfResult) {
                result = _candidate[ctxId][i];
                voteOfResult = _vote[ctxId][_candidate[ctxId][i]];
            }
        }
        require(voteOfResult >= (sumOfCVote + 1) / 2);
        return result;
    }

    function setPermittedSigner(address permittedSigner) public {
        require(msg.sender == _owner);
        _permittedSigner[permittedSigner] = true;
    }

    function vote(uint256 ctxId, string calldata result) public {
        require(_permittedSigner[msg.sender]);
        _vote[ctxId][result]++;
        bool voted;
        for (uint256 i = 0; i < _candidate[ctxId].length; i++) {
            if (equalString(_candidate[ctxId][i], result)) {
                voted = true;
                break;
            }
        }
        if (!voted) {
            _candidate[ctxId].push(result);
        }
    }
}
