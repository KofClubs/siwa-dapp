const SignatureVerifier = artifacts.require('SignatureVerifier')

const TruffleAssert = require('truffle-assertions')

contract('SignatureVerifier', accounts => {
    const expectedOwner = accounts[0]
    const g2Element1xx = web3.utils.toBN('0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2')
    const g2Element1xy = web3.utils.toBN('0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed')
    const g2Element1yx = web3.utils.toBN('0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b')
    const g2Element1yy = web3.utils.toBN('0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa')
    const publicKey1xx = web3.utils.toBN('0x209dd15ebff5d46c4bd888e51a93cf99a7329636c63514396b4a452003a35bf7')
    const publicKey1xy = web3.utils.toBN('0x04bf11ca01483bfa8b34b43561848d28905960114c8ac04049af4b6315a41678')
    const publicKey1yx = web3.utils.toBN('0x2bb8324af6cfc93537a2ad1a445cfd0ca2a71acd7ac41fadbf933c2a51be344d')
    const publicKey1yy = web3.utils.toBN('0x120a2a4cf30c1bf9845f20c6fe39e07ea2cce61f0c9bb048165fe5e4de877550')
    const messageHash1x = web3.utils.toBN('0x1c76476f4def4bb94541d57ebba1193381ffa7aa76ada664dd31c16024c43f59')
    const messageHash1y = web3.utils.toBN('0x3034dd2920f673e204fee2811c678745fc819b55d3e9d294e45c9b03a76aef41')
    const signature1x = web3.utils.toBN('0x111e129f1cf1097710d41c4ac70fcdfa5ba2023c6ff1cbeac322de49d1b6df7c')
    const signature1y = web3.utils.toBN('0x2032c61a830e3c17286de9462bf242fca2883585b93870a73853face6a6bf411')
    const signature2x = web3.utils.toBN('0x06967a1237ebfeca9aaae0d6d0bab8e28c198c5a339ef8a2407e31cdac516db9')
    const signature2y = web3.utils.toBN('0x22160fa257a5fd5b280642ff47b65eca77e626cb685c84fa6d3b6882a283ddd1')

    beforeEach('deploy testing contract, execute setActualNodeToGroup, setExpectedNodeToGroup', async () => {
        instance = await SignatureVerifier.new()
        await instance.setG2Element(g2Element1xx, g2Element1xy, g2Element1yx, g2Element1yy, {
            from: accounts[0]
        })
        await instance.setPublicKey(publicKey1xx, publicKey1xy, publicKey1yx, publicKey1yy, {
            from: accounts[0]
        })
    })

    describe('test constructor', async () => {
        it('owner shall be accounts[0]', async () => {
            let actualOwner = await instance.getOwner()
            assert.equal(actualOwner, expectedOwner, 'wrong owner')
        })
    })

    describe('test verify', async () => {
        it('test verify (correct signature)', async () => {
            let verifyResult = await instance.verify(1, messageHash1x, messageHash1y, signature1x, signature1y)
            TruffleAssert.eventEmitted(verifyResult, 'SignatureVerified', (ev) => {
                return ev.ctxId.toString() === '1' && ev.result
            }, 'SignatureVerified not emitted')
        })
        it('test verify (incorrect signature)', async () => {
            let verifyResult = await instance.verify(1, messageHash1x, messageHash1y, signature2x, signature2y)
            TruffleAssert.eventEmitted(verifyResult, 'SignatureVerified', (ev) => {
                return ev.ctxId.toString() === '1' && !ev.result
            }, 'SignatureVerified not emitted')
        })
    })
})
