const OnChainScheduler = artifacts.require('OnChainScheduler')

const TruffleAssert = require('truffle-assertions')

contract('OnChainScheduler', accounts => {
    const expectedOwner = accounts[0]

    beforeEach('deploy testing contract', async () => {
        instance = await OnChainScheduler.new()
    })

    describe('test constructor', async () => {
        it('owner shall be accounts[0]', async () => {
            let actualOwner = await instance.getOwner()
            assert.equal(actualOwner, expectedOwner, 'wrong owner')
        })
    })

    describe('test all public functions', async () => {
        it('test all public functions', async () => {
            /****** new group 1, 2; delete group 1, 2 ******/
            let newGroup1Result = await instance.newGroup({
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(newGroup1Result, 'GroupNewed', (ev) => {
                return ev.id.toString() === '1'
            }, 'GroupNewed not emitted')

            let newGroup2Result = await instance.newGroup({
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(newGroup2Result, 'GroupNewed', (ev) => {
                return ev.id.toString() === '2'
            }, 'GroupNewed not emitted')

            let deleteGroup1Result = await instance.deleteGroup(1, {
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(deleteGroup1Result, 'GroupDeletedWithTransfer', (ev) => {
                return ev.from.toString() === '1' && ev.to.toString() === '2' && ev.size.toString() === '0'
            }, 'GroupDeletedWithTransfer not emitted')

            let deleteGroup2Result = await instance.deleteGroup(2, {
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(deleteGroup2Result, 'GroupDeletedWithoutTransfer', (ev) => {
                return ev.id.toString() === '2' && ev.size.toString() === '0'
            }, 'GroupDeletedWithoutTransfer not emitted')

            /****** increase size of group 3, decrease size of group 3 ******/
            let newGroup3Result = await instance.newGroup({
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(newGroup3Result, 'GroupNewed', (ev) => {
                return ev.id.toString() === '3'
            }, 'GroupNewed not emitted')

            let increaseGroup3SizeResult = await instance.increaseGroupSize(3, {
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(increaseGroup3SizeResult, 'GroupSizeUpdated', (ev) => {
                return ev.id.toString() === '3' && ev.size.toString() === '1'
            }, 'GroupSizeUpdated not emitted')

            let decreaseGroup3SizeResult = await instance.decreaseGroupSize(3, {
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(decreaseGroup3SizeResult, 'GroupSizeUpdated', (ev) => {
                return ev.id.toString() === '3' && ev.size.toString() === '0'
            }, 'GroupSizeUpdated not emitted')
        })
    })
})
