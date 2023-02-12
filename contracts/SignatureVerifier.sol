// contracts/SignatureVerifier.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./BN256G1.sol";

contract SignatureVerifier {
    address private _owner;
    // pk = {_g2Element}^{sk}
    uint256[4] private _g2Element;
    // todo: import PublicKeyRegistry to get it
    uint256[4] private _publicKey;

    constructor() public {
        _owner = msg.sender;
    }

    event SignatureVerified(uint256 ctxId, bool result);

    function getOwner() public view returns (address) {
        return _owner;
    }

    function setG2Element(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) public {
        require(msg.sender == _owner);
        _g2Element[0] = xx;
        _g2Element[1] = xy;
        _g2Element[2] = yx;
        _g2Element[3] = yy;
    }

    function setPublicKey(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) public {
        require(msg.sender == _owner);
        _publicKey[0] = xx;
        _publicKey[1] = xy;
        _publicKey[2] = yx;
        _publicKey[3] = yy;
    }

    function verify(
        uint256 ctxId,
        uint256 messageHashX,
        uint256 messageHashY,
        uint256 signatureX,
        uint256 signatureY
    ) public returns (bool) {
        bool result = BN256G1.bn256CheckPairing(
            [
                messageHashX,
                messageHashY,
                _publicKey[0],
                _publicKey[1],
                _publicKey[2],
                _publicKey[3],
                signatureX,
                signatureY,
                _g2Element[0],
                _g2Element[1],
                _g2Element[2],
                _g2Element[3]
            ]
        );
        emit SignatureVerified(ctxId, result);
        return result;
    }
}
