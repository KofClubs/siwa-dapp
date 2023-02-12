// contracts/BN256G2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library BN256G2 {
    uint256 internal constant FIELD_MODULUS =
        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
    uint256 internal constant TWISTBX =
        0x2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5;
    uint256 internal constant TWISTBY =
        0x9713b03af0fed4cd2cafadeed8fdf4a74fa084e52d1852e4a2bd0685c315d2;
    uint256 internal constant PTXX = 0;
    uint256 internal constant PTXY = 1;
    uint256 internal constant PTYX = 2;
    uint256 internal constant PTYY = 3;
    uint256 internal constant PTZX = 4;
    uint256 internal constant PTZY = 5;
    uint256 public constant G2_NEG_X_RE =
        0x198E9393920D483A7260BFB731FB5D25F1AA493335A9E71297E485B7AEF312C2;
    uint256 public constant G2_NEG_X_IM =
        0x1800DEEF121F1E76426A00665E5C4479674322D4F75EDADD46DEBD5CD992F6ED;
    uint256 public constant G2_NEG_Y_RE =
        0x275dc4a288d1afb3cbb1ac09187524c7db36395df7be3b99e673b13a075a65ec;
    uint256 public constant G2_NEG_Y_IM =
        0x1d9befcd05a5323e6da4d435f3b617cdb3af83285c2df711ef39c01571827f9d;

    function ecTwistAdd(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt2xx,
        uint256 pt2xy,
        uint256 pt2yx,
        uint256 pt2yy
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (pt1xx == 0 && pt1xy == 0 && pt1yx == 0 && pt1yy == 0) {
            if (!(pt2xx == 0 && pt2xy == 0 && pt2yx == 0 && pt2yy == 0)) {
                require(_isOnCurve(pt2xx, pt2xy, pt2yx, pt2yy));
            }
            return (pt2xx, pt2xy, pt2yx, pt2yy);
        } else if (pt2xx == 0 && pt2xy == 0 && pt2yx == 0 && pt2yy == 0) {
            require(_isOnCurve(pt1xx, pt1xy, pt1yx, pt1yy));
            return (pt1xx, pt1xy, pt1yx, pt1yy);
        }
        require(_isOnCurve(pt1xx, pt1xy, pt1yx, pt1yy));
        require(_isOnCurve(pt2xx, pt2xy, pt2yx, pt2yy));
        uint256[6] memory pt3 = ecTwistAddJacobian(
            pt1xx,
            pt1xy,
            pt1yx,
            pt1yy,
            1,
            0,
            pt2xx,
            pt2xy,
            pt2yx,
            pt2yy,
            1,
            0
        );
        return
            _fromJacobian(
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            );
    }

    function ecTwistMul(
        uint256 s,
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 pt1zx = 1;
        if (pt1xx == 0 && pt1xy == 0 && pt1yx == 0 && pt1yy == 0) {
            pt1xx = 1;
            pt1yx = 1;
            pt1zx = 0;
        } else {
            require(_isOnCurve(pt1xx, pt1xy, pt1yx, pt1yy));
        }
        uint256[6] memory pt2 = _ecTwistMulJacobian(
            s,
            pt1xx,
            pt1xy,
            pt1yx,
            pt1yy,
            pt1zx,
            0
        );
        return
            _fromJacobian(
                pt2[PTXX],
                pt2[PTXY],
                pt2[PTYX],
                pt2[PTYY],
                pt2[PTZX],
                pt2[PTZY]
            );
    }

    function getFieldModulus() external pure returns (uint256) {
        return FIELD_MODULUS;
    }

    function submod(
        uint256 a,
        uint256 b,
        uint256 n
    ) internal pure returns (uint256) {
        return addmod(a, n - b, n);
    }

    function _fq2mul(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) internal pure returns (uint256, uint256) {
        return (
            submod(
                mulmod(xx, yx, FIELD_MODULUS),
                mulmod(xy, yy, FIELD_MODULUS),
                FIELD_MODULUS
            ),
            addmod(
                mulmod(xx, yy, FIELD_MODULUS),
                mulmod(xy, yx, FIELD_MODULUS),
                FIELD_MODULUS
            )
        );
    }

    function _fq2muc(
        uint256 xx,
        uint256 xy,
        uint256 k
    ) internal pure returns (uint256, uint256) {
        return (mulmod(xx, k, FIELD_MODULUS), mulmod(xy, k, FIELD_MODULUS));
    }

    function _fq2add(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) internal pure returns (uint256, uint256) {
        return (addmod(xx, yx, FIELD_MODULUS), addmod(xy, yy, FIELD_MODULUS));
    }

    function _fq2sub(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) internal pure returns (uint256, uint256) {
        return (submod(xx, yx, FIELD_MODULUS), submod(xy, yy, FIELD_MODULUS));
    }

    function _fq2div(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) internal view returns (uint256, uint256) {
        (yx, yy) = _fq2inv(yx, yy);
        return _fq2mul(xx, xy, yx, yy);
    }

    function _fq2inv(uint256 x, uint256 y)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 inv = _modInv(
            addmod(
                mulmod(y, y, FIELD_MODULUS),
                mulmod(x, x, FIELD_MODULUS),
                FIELD_MODULUS
            ),
            FIELD_MODULUS
        );
        return (
            mulmod(x, inv, FIELD_MODULUS),
            FIELD_MODULUS - mulmod(y, inv, FIELD_MODULUS)
        );
    }

    function _isOnCurve(
        uint256 xx,
        uint256 xy,
        uint256 yx,
        uint256 yy
    ) internal pure returns (bool) {
        uint256 yyx;
        uint256 yyy;
        uint256 xxxx;
        uint256 xxxy;
        (yyx, yyy) = _fq2mul(yx, yy, yx, yy);
        (xxxx, xxxy) = _fq2mul(xx, xy, xx, xy);
        (xxxx, xxxy) = _fq2mul(xxxx, xxxy, xx, xy);
        (yyx, yyy) = _fq2sub(yyx, yyy, xxxx, xxxy);
        (yyx, yyy) = _fq2sub(yyx, yyy, TWISTBX, TWISTBY);
        return yyx == 0 && yyy == 0;
    }

    function _modInv(uint256 a, uint256 n)
        internal
        view
        returns (uint256 result)
    {
        bool success;
        assembly {
            let freemem := mload(0x40)
            mstore(freemem, 0x20)
            mstore(add(freemem, 0x20), 0x20)
            mstore(add(freemem, 0x40), 0x20)
            mstore(add(freemem, 0x60), a)
            mstore(add(freemem, 0x80), sub(n, 2))
            mstore(add(freemem, 0xA0), n)
            success := staticcall(
                sub(gas(), 2000),
                5,
                freemem,
                0xC0,
                freemem,
                0x20
            )
            result := mload(freemem)
        }
        require(success);
    }

    function _fromJacobian(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 invzx;
        uint256 invzy;
        uint256[4] memory pt2;
        (invzx, invzy) = _fq2inv(pt1zx, pt1zy);
        (pt2[0], pt2[1]) = _fq2mul(pt1xx, pt1xy, invzx, invzy);
        (pt2[2], pt2[3]) = _fq2mul(pt1yx, pt1yy, invzx, invzy);
        return (pt2[0], pt2[1], pt2[2], pt2[3]);
    }

    function ecTwistAddJacobian(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy,
        uint256 pt2xx,
        uint256 pt2xy,
        uint256 pt2yx,
        uint256 pt2yy,
        uint256 pt2zx,
        uint256 pt2zy
    ) internal pure returns (uint256[6] memory pt3) {
        if (pt1zx == 0 && pt1zy == 0) {
            (
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            ) = (pt2xx, pt2xy, pt2yx, pt2yy, pt2zx, pt2zy);
            return pt3;
        } else if (pt2zx == 0 && pt2zy == 0) {
            (
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            ) = (pt1xx, pt1xy, pt1yx, pt1yy, pt1zx, pt1zy);
            return pt3;
        }
        (pt2yx, pt2yy) = _fq2mul(pt2yx, pt2yy, pt1zx, pt1zy);
        (pt3[PTYX], pt3[PTYY]) = _fq2mul(pt1yx, pt1yy, pt2zx, pt2zy);
        (pt2xx, pt2xy) = _fq2mul(pt2xx, pt2xy, pt1zx, pt1zy);
        (pt3[PTZX], pt3[PTZY]) = _fq2mul(pt1xx, pt1xy, pt2zx, pt2zy);
        if (pt2xx == pt3[PTZX] && pt2xy == pt3[PTZY]) {
            if (pt2yx == pt3[PTYX] && pt2yy == pt3[PTYY]) {
                (
                    pt3[PTXX],
                    pt3[PTXY],
                    pt3[PTYX],
                    pt3[PTYY],
                    pt3[PTZX],
                    pt3[PTZY]
                ) = _ecTwistDoubleJacobian(
                    pt1xx,
                    pt1xy,
                    pt1yx,
                    pt1yy,
                    pt1zx,
                    pt1zy
                );
                return pt3;
            }
            (
                pt3[PTXX],
                pt3[PTXY],
                pt3[PTYX],
                pt3[PTYY],
                pt3[PTZX],
                pt3[PTZY]
            ) = (1, 0, 1, 0, 0, 0);
            return pt3;
        }
        (pt2zx, pt2zy) = _fq2mul(pt1zx, pt1zy, pt2zx, pt2zy);
        (pt1xx, pt1xy) = _fq2sub(pt2yx, pt2yy, pt3[PTYX], pt3[PTYY]);
        (pt1yx, pt1yy) = _fq2sub(pt2xx, pt2xy, pt3[PTZX], pt3[PTZY]);
        (pt1zx, pt1zy) = _fq2mul(pt1yx, pt1yy, pt1yx, pt1yy);
        (pt2yx, pt2yy) = _fq2mul(pt1zx, pt1zy, pt3[PTZX], pt3[PTZY]);
        (pt1zx, pt1zy) = _fq2mul(pt1zx, pt1zy, pt1yx, pt1yy);
        (pt3[PTZX], pt3[PTZY]) = _fq2mul(pt1zx, pt1zy, pt2zx, pt2zy);
        (pt2xx, pt2xy) = _fq2mul(pt1xx, pt1xy, pt1xx, pt1xy);
        (pt2xx, pt2xy) = _fq2mul(pt2xx, pt2xy, pt2zx, pt2zy);
        (pt2xx, pt2xy) = _fq2sub(pt2xx, pt2xy, pt1zx, pt1zy);
        (pt2zx, pt2zy) = _fq2muc(pt2yx, pt2yy, 2);
        (pt2xx, pt2xy) = _fq2sub(pt2xx, pt2xy, pt2zx, pt2zy);
        (pt3[PTXX], pt3[PTXY]) = _fq2mul(pt1yx, pt1yy, pt2xx, pt2xy);
        (pt1yx, pt1yy) = _fq2sub(pt2yx, pt2yy, pt2xx, pt2xy);
        (pt1yx, pt1yy) = _fq2mul(pt1xx, pt1xy, pt1yx, pt1yy);
        (pt1xx, pt1xy) = _fq2mul(pt1zx, pt1zy, pt3[PTYX], pt3[PTYY]);
        (pt3[PTYX], pt3[PTYY]) = _fq2sub(pt1yx, pt1yy, pt1xx, pt1xy);
    }

    function _ecTwistDoubleJacobian(
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy
    )
        internal
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256[6] memory pt2;
        (pt2[0], pt2[1]) = _fq2muc(pt1xx, pt1xy, 3);
        (pt2[0], pt2[1]) = _fq2mul(pt2[0], pt2[1], pt1xx, pt1xy);
        (pt1zx, pt1zy) = _fq2mul(pt1yx, pt1yy, pt1zx, pt1zy);
        (pt2[2], pt2[3]) = _fq2mul(pt1xx, pt1xy, pt1yx, pt1yy);
        (pt2[2], pt2[3]) = _fq2mul(pt2[2], pt2[3], pt1zx, pt1zy);
        (pt1xx, pt1xy) = _fq2mul(pt2[0], pt2[1], pt2[0], pt2[1]);
        (pt2[4], pt2[5]) = _fq2muc(pt2[2], pt2[3], 8);
        (pt1xx, pt1xy) = _fq2sub(pt1xx, pt1xy, pt2[4], pt2[5]);
        (pt2[4], pt2[5]) = _fq2mul(pt1zx, pt1zy, pt1zx, pt1zy);
        (pt2[2], pt2[3]) = _fq2muc(pt2[2], pt2[3], 4);
        (pt2[2], pt2[3]) = _fq2sub(pt2[2], pt2[3], pt1xx, pt1xy);
        (pt2[2], pt2[3]) = _fq2mul(pt2[2], pt2[3], pt2[0], pt2[1]);
        (pt2[0], pt2[1]) = _fq2muc(pt1yx, pt1yy, 8);
        (pt2[0], pt2[1]) = _fq2mul(pt2[0], pt2[1], pt1yx, pt1yy);
        (pt2[0], pt2[1]) = _fq2mul(pt2[0], pt2[1], pt2[4], pt2[5]);
        (pt2[2], pt2[3]) = _fq2sub(pt2[2], pt2[3], pt2[0], pt2[1]);
        (pt2[0], pt2[1]) = _fq2muc(pt1xx, pt1xy, 2);
        (pt2[0], pt2[1]) = _fq2mul(pt2[0], pt2[1], pt1zx, pt1zy);
        (pt2[4], pt2[5]) = _fq2mul(pt1zx, pt1zy, pt2[4], pt2[5]);
        (pt2[4], pt2[5]) = _fq2muc(pt2[4], pt2[5], 8);
        return (pt2[0], pt2[1], pt2[2], pt2[3], pt2[4], pt2[5]);
    }

    function _ecTwistMulJacobian(
        uint256 d,
        uint256 pt1xx,
        uint256 pt1xy,
        uint256 pt1yx,
        uint256 pt1yy,
        uint256 pt1zx,
        uint256 pt1zy
    ) internal pure returns (uint256[6] memory) {
        uint256[6] memory pt2;
        while (d != 0) {
            if ((d & 1) != 0) {
                pt2 = ecTwistAddJacobian(
                    pt2[PTXX],
                    pt2[PTXY],
                    pt2[PTYX],
                    pt2[PTYY],
                    pt2[PTZX],
                    pt2[PTZY],
                    pt1xx,
                    pt1xy,
                    pt1yx,
                    pt1yy,
                    pt1zx,
                    pt1zy
                );
            }
            (pt1xx, pt1xy, pt1yx, pt1yy, pt1zx, pt1zy) = _ecTwistDoubleJacobian(
                pt1xx,
                pt1xy,
                pt1yx,
                pt1yy,
                pt1zx,
                pt1zy
            );
            d = d / 2;
        }
        return pt2;
    }
}
