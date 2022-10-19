const Yamljs = require('yamljs')
const config = Yamljs.load('./config.yml')

const Web3 = require('web3')
const web3 = new Web3()
web3.setProvider(new web3.providers.HttpProvider(config.ethereum.protocol + '://' + config.ethereum.addr))

const Readline = require('readline')
const readline = Readline.createInterface({
    input: process.stdin,
    output: process.stdout
})

const Fs = require('fs');
const onChainSchedulerJson = Fs.readFileSync('./build/OnChainScheduler.abi');
const onChainSchedulerAbi = JSON.parse(onChainSchedulerJson);
const onChainSchedulerContract = new web3.eth.Contract(onChainSchedulerAbi, config.on_chain_scheduler.contract_address, {
    gas: config.ethereum.gas,
    gasPrice: config.ethereum.gas_price
})

console.log("The on-chain scheduler supports these functions:")
console.log("0. registerAggregator")
console.log("1. deregisterAggregator")
console.log("2. assignAggregator")
console.log("3. increaseDkgCapacity")
console.log("4. decreaseDkgCapacity")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '0':
            executeRegisterAggregator()
            break
        case '1':
            executeDeregisterAggregator()
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

function executeRegisterAggregator() {
    onChainSchedulerContract.methods.registerAggregator().send({
        from: config.on_chain_scheduler.aggregator_addresses[0]
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeDeregisterAggregator() {
    onChainSchedulerContract.methods.deregisterAggregator().send({
        from: config.on_chain_scheduler.aggregator_addresses[0]
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeAssignAggregator() {
    onChainSchedulerContract.methods.assignAggregator().send({
        from: config.on_chain_scheduler.owner_address
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeIncreaseDkgCapacity() {
    readline.question('Type the NFT ID:\n', _nftId => {
        onChainSchedulerContract.methods.increaseDkgCapacity(_nftId).send({
            from: config.on_chain_scheduler.aggregator_addresses[0]
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeDecreaseDkgCapacity() {
    readline.question('Type the NFT ID:\n', _nftId => {
        onChainSchedulerContract.methods.decreaseDkgCapacity(_nftId).send({
            from: config.on_chain_scheduler.aggregator_addresses[0]
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}
