const PublicKeyRegistry = artifacts.require('PublicKeyRegistry')

const TruffleAssert = require('truffle-assertions')

contract('PublicKeyRegistry', accounts => {
    const expectedOwner = accounts[0]
    // pk1 + pk2 = pk3
    const pk1xx = web3.utils.toBN('0x1d6b92aa7215a4a8cb4058046795f286ba64cf6d587da888ce4a174b83786796')
    const pk1xy = web3.utils.toBN('0x15afa104df881bb019cf06bc6e2751fd92d4d5e648ca79686cd3b7e282a99971')
    const pk1yx = web3.utils.toBN('0x0400ab98a6de8825ba644f7b593cacb1e30f46d42d7f28349dcc651499429cc8')
    const pk1yy = web3.utils.toBN('0x2519524f0d0953448e48fbaa1410ec7cd2b92746fcd1a91529a60de7d61ec09b')
    const pk2xx = web3.utils.toBN('0x27c0a659e43c0be5c92fd146b10812933b5ada045703fe9cf822e5b8e5f425fa')
    const pk2xy = web3.utils.toBN('0x152f75c943ec0d7fc1a3b0936edb20fc6ca08ae27703140727d04e697185afda')
    const pk2yx = web3.utils.toBN('0x154eb77f49cac54f164d1a96ac47bc7b89076755846f84c87a8c12a7fbba6484')
    const pk2yy = web3.utils.toBN('0x219b10f5452d1e140ab88db9ede37dfd6c452214a9bc6a3eeac70afd42f3fcb8')
    const pk3xx = web3.utils.toBN('0x19969e1b15ddc627fca32b1396d8b0b965dad62f63cc96da6e5a64c5a8c591aa')
    const pk3xy = web3.utils.toBN('0x1e97d007d9a26bfb87452dcb5fdccaaa43e6a9362ab2c6e4f619d45b53ba35b2')
    const pk3yx = web3.utils.toBN('0x08e075836b61edb61c9f7c710c4c77fdb24d2e10b070307cd689c99fbfd147e5')
    const pk3yy = web3.utils.toBN('0x2cab5d238910cd06fa3f15d86d2597f9ddae6abc926f60e550be101c6c46f216')

    beforeEach('deploy testing contract, execute setActualNodeToGroup, setExpectedNodeToGroup', async () => {
        instance = await PublicKeyRegistry.new()
        await instance.setActualNodeToGroup(accounts[1], 1, {
            from: accounts[0]
        })
        await instance.setActualNodeToGroup(accounts[2], 2, {
            from: accounts[0]
        })
        await instance.setExpectedNodeToGroup(accounts[3], 2, {
            from: accounts[0]
        })
    })

    describe('test constructor', async () => {
        it('owner shall be accounts[0]', async () => {
            let actualOwner = await instance.getOwner()
            assert.equal(actualOwner, expectedOwner, 'wrong owner')
        })
    })

    describe('test updateActualPublicKey', async () => {
        it('test updateActualPublicKey', async () => {
            let updateActualPublicKeyResult = await instance.updateActualPublicKey(1, pk1xx, pk1xy, pk1yx, pk1yy, {
                from: accounts[1]
            })
            TruffleAssert.eventEmitted(updateActualPublicKeyResult, 'ActualPublicKeyUpdated', (ev) => {
                return ev.groupId.toString() === '1' && ev.xx.toString() === pk1xx.toString() && ev.xy.toString() === pk1xy.toString() && ev.yx.toString() === pk1yx.toString() && ev.yy.toString() === pk1yy.toString()
            }, 'ActualPublicKeyUpdated not emitted')
        })
    })

    describe('test addToExpectedPublicKey', async () => {
        it('test updateActualPublicKey', async () => {
            let updateActualPublicKeyResult = await instance.updateActualPublicKey(2, pk1xx, pk1xy, pk1yx, pk1yy, {
                from: accounts[2]
            })
            TruffleAssert.eventEmitted(updateActualPublicKeyResult, 'ActualPublicKeyUpdated', (ev) => {
                return ev.groupId.toString() === '2' && ev.xx.toString() === pk1xx.toString() && ev.xy.toString() === pk1xy.toString() && ev.yx.toString() === pk1yx.toString() && ev.yy.toString() === pk1yy.toString()
            }, 'ActualPublicKeyUpdated not emitted')
            await instance.setExpectedPublicKeyToActual(2, {
                from: accounts[0]
            })
            let addToExpectedPublicKeyResult = await instance.addToExpectedPublicKey(2, pk2xx, pk2xy, pk2yx, pk2yy, {
                from: accounts[3]
            })
            TruffleAssert.eventEmitted(addToExpectedPublicKeyResult, 'ExpectedPublicKeyUpdated', (ev) => {
                return ev.groupId.toString() === '2' && ev.xx.toString() === pk3xx.toString() && ev.xy.toString() === pk3xy.toString() && ev.yx.toString() === pk3yx.toString() && ev.yy.toString() === pk3yy.toString()
            }, 'ExpectedPublicKeyUpdated not emitted')
        })
    })
})
