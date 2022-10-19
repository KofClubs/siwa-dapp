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

const onChainSchedulerAbi = require('./build/contracts/OnChainScheduler.json').abi
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
            registerAggregator()
            break
        case '1':
            deregisterAggregator()
            break
        case '2':
            assignAggregator()
            break
        case '3':
            increaseDkgCapacity()
            break
        case '4':
            decreaseDkgCapacity()
            break
        default:
            process.exit()
    }
})

function executeRegisterAggregator() {
    onChainSchedulerContract.methods.registerAggregator().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeDeregisterAggregator() {
    onChainSchedulerContract.methods.deregisterAggregator().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeAssignAggregator() {
    onChainSchedulerContract.methods.assignAggregator().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeIncreaseDkgCapacity() {
    readline.question('Type the NFT ID:\n', _nftId => {
        onChainSchedulerContract.methods.increaseDkgCapacity(_nftId).call().then(result => {
            console.log(result)
        })
        readline.close()
    })
}

function executeDecreaseDkgCapacity() {
    readline.question('Type the NFT ID:\n', _nftId => {
        onChainSchedulerContract.methods.decreaseDkgCapacity(_nftId).call().then(result => {
            console.log(result)
        })
        readline.close()
    })
}
