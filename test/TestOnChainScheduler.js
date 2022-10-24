const OnChainScheduler = artifacts.require('OnChainScheduler')

const TruffleAssert = require('truffle-assertions')

contract('OnChainScheduler', accounts => {
    const expectedName = 'SiwaNFT'
    const expectedSymbol = 'SIWA'

    beforeEach('deploy testing contract', async () => {
        instance = await OnChainScheduler.new()
    })

    describe('test constructor', async () => {
        it('name shall be "' + expectedName + '"', async () => {
            let _name = await instance.name()
            assert.equal(_name, expectedName, 'wrong name')
        })

        it('symbol shall be "' + expectedSymbol + '"', async () => {
            let _symbol = await instance.symbol()
            assert.equal(_symbol, expectedSymbol, 'wrong symbol')
        })
    })

    describe('test functions', async () => {
        it('test all public functions', async () => {
            let activateAggregatorResult = await instance.activateAggregator({
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(activateAggregatorResult, 'AggregatorActivated', (ev) => {
                return ev.aggregatorId.toString() === '0'
            }, 'AggregatorActivated not emitted')

            let assignAggregatorResult = await instance.assignAggregator()
            assert.equal(assignAggregatorResult.toString(), '0', 'wrong aggregator id')

            let increaseDkgCapacityResult = await instance.increaseDkgCapacity(0, {
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(increaseDkgCapacityResult, 'DkgCapacityIncreased', (ev) => {
                return ev.aggregatorId.toString() === '0' && ev.dkgCapacity.toString() === '1'
            }, 'DkgCapacityIncreased not emitted')

            let decreaseDkgCapacityResult = await instance.decreaseDkgCapacity(0, {
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(decreaseDkgCapacityResult, 'DkgCapacityDecreased', (ev) => {
                return ev.aggregatorId.toString() === '0' && ev.dkgCapacity.toString() === '0'
            }, 'DkgCapacityDecreased not emitted')

            let deactivateAggregatorResult = await instance.deactivateAggregator({
                from: accounts[0]
            })
            TruffleAssert.eventEmitted(deactivateAggregatorResult, 'AggregatorDeactivated', (ev) => {
                return ev.aggregatorId.toString() === '0'
            }, 'AggregatorDeactivated not emitted')
        })
    })
})