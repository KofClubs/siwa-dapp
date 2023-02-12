const OnChainAggregator = artifacts.require('OnChainAggregator')

contract('OnChainAggregator', accounts => {
    const expectedOwner = accounts[0]
    const countOfT = 2
    const countOfF = 1
    const expectedResult = 't'

    beforeEach('deploy testing contract, execute setPermittedSigner', async () => {
        instance = await OnChainAggregator.new()
        await instance.setPermittedSigner(accounts[1], {
            from: accounts[0]
        })
    })

    describe('test constructor', async () => {
        it('owner shall be accounts[0]', async () => {
            let actualOwner = await instance.getOwner()
            assert.equal(actualOwner, expectedOwner, 'wrong owner')
        })
    })

    describe('test vote, getResult', async () => {
        it('vote t*countOfT, f*countOfF, result shall be t', async () => {
            for (var i = 0; i < countOfT; i++) {
                await instance.vote(1, 't', {
                    from: accounts[1]
                })
            }
            for (var j = 0; j < countOfF; j++) {
                await instance.vote(1, 'f', {
                    from: accounts[1]
                })
            }
            let actualResult = await instance.getResult(1)
            assert.equal(actualResult, expectedResult, 'wrong result')
        })
    })
})
