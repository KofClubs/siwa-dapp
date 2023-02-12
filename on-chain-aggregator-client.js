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
const OnChainAggregatorJson = Fs.readFileSync('./abi/OnChainAggregator.abi');
const OnChainAggregatorAbi = JSON.parse(OnChainAggregatorJson);
const OnChainAggregatorContract = new web3.eth.Contract(OnChainAggregatorAbi, Config.get('on_chain_aggregator.contract_address'), {
    gas: Config.get('ethereum.gas'),
    gasPrice: Config.get('ethereum.gas_price')
})

console.log("The on-chain scheduler supports these functions:")
console.log("1. getOwner")
console.log("2. getResult")
console.log("3. setPermittedSigner")
console.log("4. vote")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '1':
            executeGetOwner()
            break
        case '2':
            executeGetResult()
            break
        case '3':
            executeSetPermittedSigner()
            break
        case '4':
            executeVote()
            break
        default:
            process.exit()
    }
})

function executeGetOwner() {
    OnChainAggregatorContract.methods.getOwner().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeGetResult() {
    readline.question('Type the id of ctx:\n', ctxId => {
        OnChainAggregatorContract.methods.getResult(ctxId).call().then(result => {
            console.log(result)
        })
        readline.close()
    })
}

function executeSetPermittedSigner() {
    OnChainAggregatorContract.methods.setPermittedSigner(Config.get('on_chain_aggregator.permitted_signer')).send({
        from: Config.get('on_chain_aggregator.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeVote() {
    readline.question('Type the id of ctx:\n', ctxId => {
        readline.question('Type the result:\n', result => {
            OnChainAggregatorContract.methods.vote(ctxId, result).send({
                from: Config.get('on_chain_aggregator.permitted_signer')
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}
