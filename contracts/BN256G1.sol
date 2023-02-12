// contracts/BN256G1.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../node_modules/elliptic-curve-solidity/contracts/EllipticCurve.sol";

library BN256G1 {
    uint256 public constant GX = 1;
    uint256 public constant GY = 2;
    uint256 internal constant AA = 0;
    uint256 internal constant BB = 3;
    uint256 internal constant PP =
        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
    uint256 internal constant NN =
        0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;
    uint256 internal constant LAST_MULTIPLE_OF_PP_LOWER_THAN_2_256 =
        0xf1f5883e65f820d099915c908786b9d3f58714d70a38f4c22ca2bc723a70f263;

    function add(uint256[4] memory input) internal returns (uint256, uint256) {
        bool success;
        uint256[2] memory result;
        assembly {
            success := call(not(0), 0x06, 0, input, 128, result, 64)
        }
        require(success);
        return (result[0], result[1]);
    }

    function multiply(uint256[3] memory input)
        internal
        returns (uint256, uint256)
    {
        bool success;
        uint256[2] memory result;
        assembly {
            success := call(not(0), 0x07, 0, input, 96, result, 64)
        }
        require(success);
        return (result[0], result[1]);
    }

    function isOnCurve(uint256[2] memory point) internal pure returns (bool) {
        return EllipticCurve.isOnCurve(point[0], point[1], AA, BB, PP);
    }

    function bn256CheckPairing(uint256[12] memory input)
        internal
        returns (bool)
    {
        uint256[1] memory result;
        bool success;
        assembly {
            success := call(sub(gas(), 2000), 0x08, 0, input, 384, result, 32)
        }
        require(success);
        return result[0] == 1;
    }

    function bn256CheckPairingBatch(uint256[] memory input)
        internal
        returns (bool)
    {
        uint256[1] memory result;
        bool success;
        require(input.length % 6 == 0);
        uint256 inLen = input.length * 32;
        assembly {
            success := call(
                sub(gas(), 2000),
                0x08,
                0,
                add(input, 0x20),
                inLen,
                result,
                32
            )
        }
        require(success);
        return result[0] == 1;
    }

    function fromCompressed(bytes memory _point)
        internal
        pure
        returns (uint256, uint256)
    {
        require(_point.length == 33);
        uint8 sign;
        uint256 x;
        assembly {
            sign := mload(add(_point, 1))
            x := mload(add(_point, 33))
        }
        return (x, deriveY(sign, x));
    }

    function hashToTryAndIncrement(bytes memory _message)
        internal
        pure
        returns (uint256, uint256)
    {
        for (uint8 ctr = 0; ctr < 256; ctr++) {
            bytes32 sha = sha256(abi.encodePacked(_message, ctr));
            uint256 hPointX = uint256(sha);
            if (hPointX >= LAST_MULTIPLE_OF_PP_LOWER_THAN_2_256) {
                continue;
            }
            hPointX = hPointX % PP;
            uint256 hPointY = deriveY(2, hPointX);
            if (isOnCurve([hPointX, hPointY])) {
                return (hPointX, hPointY);
            }
        }
        revert();
    }

    function deriveY(uint8 _yByte, uint256 _x) internal pure returns (uint256) {
        return EllipticCurve.deriveY(_yByte, _x, AA, BB, PP);
    }
}
