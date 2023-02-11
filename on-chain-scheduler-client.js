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
const onChainSchedulerJson = Fs.readFileSync('./abi/OnChainScheduler.abi');
const onChainSchedulerAbi = JSON.parse(onChainSchedulerJson);
const onChainSchedulerContract = new web3.eth.Contract(onChainSchedulerAbi, Config.get('on_chain_scheduler.contract_address'), {
    gas: Config.get('ethereum.gas'),
    gasPrice: Config.get('ethereum.gas_price')
})

console.log("The on-chain scheduler supports these functions:")
console.log("1. getOwner")
console.log("2. assignGroup")
console.log("3. newGroup")
console.log("4. deleteGroup")
console.log("5. increaseGroupSize")
console.log("6. decreaseGroupSize")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '1':
            executeGetOwner()
            break
        case '2':
            executeAssignGroup()
            break
        case '3':
            executeNewGroup()
            break
        case '4':
            executeDeleteGroup()
            break
        case '5':
            executeIncreaseGroupSize()
            break
        case '6':
            executeDecreaseGroupSize()
            break
        default:
            process.exit()
    }
})

function executeGetOwner() {
    onChainSchedulerContract.methods.getOwner().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeAssignGroup() {
    onChainSchedulerContract.methods.assignGroup().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeNewGroup() {
    onChainSchedulerContract.methods.newGroup().send({
        from: Config.get('on_chain_scheduler.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeDeleteGroup() {
    readline.question('Type the id of group:\n', groupId => {
        onChainSchedulerContract.methods.deleteGroup(groupId).send({
            from: Config.get('on_chain_scheduler.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeIncreaseGroupSize() {
    readline.question('Type the id of group:\n', groupId => {
        onChainSchedulerContract.methods.increaseGroupSize(groupId).send({
            from: Config.get('on_chain_scheduler.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeDecreaseGroupSize() {
    readline.question('Type the id of group:\n', groupId => {
        onChainSchedulerContract.methods.decreaseGroupSize(groupId).send({
            from: Config.get('on_chain_scheduler.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}
