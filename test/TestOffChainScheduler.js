const OffChainScheduler = artifacts.require('OffChainScheduler')

contract('OffChainScheduler', accounts => {
    const expectedOwner = accounts[0]
    const expectedScheduler = accounts[1]

    beforeEach('deploy testing contract, execute setScheduler', async () => {
        instance = await OffChainScheduler.new()
        await instance.setScheduler(accounts[1], {
            from: accounts[0]
        })
    })

    describe('test constructor, setScheduler', async () => {
        it('owner shall be accounts[0], scheduler shall be accounts[1]', async () => {
            let actualOwner = await instance.getOwner()
            assert.equal(actualOwner, expectedOwner, 'wrong owner')
            let actualScheduler = await instance.getScheduler()
            assert.equal(actualScheduler, expectedScheduler, 'wrong scheduler')
        })
    })
})
