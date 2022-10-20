const Config = require('config');

const Web3 = require('web3')
const web3 = new Web3()
web3.setProvider(new web3.providers.HttpProvider(Config.get('ethereum.protocol') + '://' + Config.get('ethereum.addr')))

const Readline = require('readline')
const readline = Readline.createInterface({
    input: process.stdin,
    output: process.stdout
})

const Fs = require('fs');
const onChainSchedulerJson = Fs.readFileSync('./build/OnChainScheduler.abi');
const onChainSchedulerAbi = JSON.parse(onChainSchedulerJson);
const onChainSchedulerContract = new web3.eth.Contract(onChainSchedulerAbi, Config.get('on_chain_scheduler.contract_address'), {
    gas: Config.get('ethereum.gas'),
    gasPrice: Config.get('ethereum.gas_price')
})

console.log("The on-chain scheduler supports these functions:")
console.log("0. activateAggregator")
console.log("1. deactivateAggregator")
console.log("2. assignAggregator")
console.log("3. increaseDkgCapacity")
console.log("4. decreaseDkgCapacity")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '0':
            executeActivateAggregator()
            break
        case '1':
            executeDeactivateAggregator()
            break
        case '2':
            executeAssignAggregator()
            break
        case '3':
            executeIncreaseDkgCapacity()
            break
        case '4':
            executeDecreaseDkgCapacity()
            break
        default:
            process.exit()
    }
})

function executeActivateAggregator() {
    readline.question('Type the rank of aggregator:\n', _rank => {
        onChainSchedulerContract.methods.activateAggregator().send({
            from: Config.get('on_chain_scheduler.aggregator_addresses')[_rank]
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeDeactivateAggregator() {
    readline.question('Type the rank of aggregator:\n', _rank => {
        onChainSchedulerContract.methods.deactivateAggregator().send({
            from: Config.get('on_chain_scheduler.aggregator_addresses')[_rank]
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeAssignAggregator() {
    onChainSchedulerContract.methods.assignAggregator().send({
        from: Config.get('on_chain_scheduler.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeIncreaseDkgCapacity() {
    readline.question('Type the rank of aggregator:\n', _rank => {
        readline.question('Type the NFT ID:\n', _nftId => {
            onChainSchedulerContract.methods.increaseDkgCapacity(_nftId).send({
                from: Config.get('on_chain_scheduler.aggregator_addresses')[_rank]
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}

function executeDecreaseDkgCapacity() {
    readline.question('Type the rank of aggregator:\n', _rank => {
        readline.question('Type the NFT ID:\n', _nftId => {
            onChainSchedulerContract.methods.decreaseDkgCapacity(_nftId).send({
                from: Config.get('on_chain_scheduler.aggregator_addresses')[_rank]
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}
