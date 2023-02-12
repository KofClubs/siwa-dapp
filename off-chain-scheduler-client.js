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
const offChainSchedulerJson = Fs.readFileSync('./abi/OffChainScheduler.abi');
const offChainSchedulerAbi = JSON.parse(offChainSchedulerJson);
const offChainSchedulerContract = new web3.eth.Contract(offChainSchedulerAbi, Config.get('off_chain_scheduler.contract_address'), {
    gas: Config.get('ethereum.gas'),
    gasPrice: Config.get('ethereum.gas_price')
})

console.log("The off-chain scheduler supports these functions:")
console.log("1. getOwner")
console.log("2. getScheduler")
console.log("3. setScheduler")
console.log("4. assignGroup")
console.log("5. handleAssignGroup")
console.log("6. newGroup")
console.log("7. deleteGroup")
console.log("8. increaseGroupSize")
console.log("9. decreaseGroupSize")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '1':
            executeGetOwner()
            break
        case '2':
            executeGetScheduler()
            break
        case '3':
            executeSetScheduler()
            break
        case '4':
            executeAssignGroup()
            break
        case '5':
            executeHandleAssignGroup()
            break
        case '6':
            executeNewGroup()
            break
        case '7':
            executeDeleteGroup()
            break
        case '8':
            executeIncreaseGroupSize()
            break
        case '9':
            executeDecreaseGroupSize()
            break
        default:
            process.exit()
    }
})

function executeGetOwner() {
    offChainSchedulerContract.methods.getOwner().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeGetScheduler() {
    offChainSchedulerContract.methods.getScheduler().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeSetScheduler() {
    offChainSchedulerContract.methods.setScheduler(Config.get('off_chain_scheduler.scheduler_address')).send({
        from: Config.get('off_chain_scheduler.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeAssignGroup() {
    offChainSchedulerContract.methods.assignGroup().send({
        from: Config.get('off_chain_scheduler.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeHandleAssignGroup() {
    readline.question('Type the id of ctx:\n', ctxId => {
        readline.question('Type the id of group:\n', groupId => {
            offChainSchedulerContract.methods.handleAssignGroup(ctxId, groupId).send({
                from: Config.get('off_chain_scheduler.scheduler_address')
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}

function executeNewGroup() {
    offChainSchedulerContract.methods.newGroup().send({
        from: Config.get('off_chain_scheduler.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeDeleteGroup() {
    readline.question('Type the id of group:\n', groupId => {
        offChainSchedulerContract.methods.deleteGroup(groupId).send({
            from: Config.get('off_chain_scheduler.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeIncreaseGroupSize() {
    readline.question('Type the id of group:\n', groupId => {
        offChainSchedulerContract.methods.increaseGroupSize(groupId).send({
            from: Config.get('off_chain_scheduler.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeDecreaseGroupSize() {
    readline.question('Type the id of group:\n', groupId => {
        offChainSchedulerContract.methods.decreaseGroupSize(groupId).send({
            from: Config.get('off_chain_scheduler.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}
