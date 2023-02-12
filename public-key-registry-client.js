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
const publicKeyRegistryJson = Fs.readFileSync('./abi/PublicKeyRegistry.abi');
const publicKeyRegistryAbi = JSON.parse(publicKeyRegistryJson);
const publicKeyRegistryContract = new web3.eth.Contract(publicKeyRegistryAbi, Config.get('public_key_registry.contract_address'), {
    gas: Config.get('ethereum.gas'),
    gasPrice: Config.get('ethereum.gas_price')
})

console.log("The public key registry supports these functions:")
console.log("1. getOwner")
console.log("2. ifActualPublicKeyEqualtoExpected")
console.log("3. setActualNodeToGroup")
console.log("4. setExpectedNodeToGroup")
console.log("5. setExpectedPublicKeyToActual")
console.log("6. updateActualPublicKey")
console.log("7. addToExpectedPublicKey")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '1':
            executeGetOwner()
            break
        case '2':
            executeIfActualPublicKeyEqualtoExpected()
            break
        case '3':
            executeSetActualNodeToGroup()
            break
        case '4':
            executeSetExpectedNodeToGroup()
            break
        case '5':
            executeSetExpectedPublicKeyToActual()
            break
        case '6':
            executeUpdateActualPublicKey()
            break
        case '7':
            executeAddToExpectedPublicKey()
            break
        default:
            process.exit()
    }
})

function executeGetOwner() {
    publicKeyRegistryContract.methods.getOwner().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeIfActualPublicKeyEqualtoExpected() {
    readline.question('Type the id of group:\n', groupId => {
        publicKeyRegistryContract.methods.ifActualPublicKeyEqualtoExpected(groupId).call().then(result => {
            console.log(result)
        })
        readline.close()
    })
}

function executeSetActualNodeToGroup() {
    readline.question('Type the id of node:\n', nodeId => {
        readline.question('Type the id of group:\n', groupId => {
            publicKeyRegistryContract.methods.setActualNodeToGroup(Config.get('public_key_registry.node.' + nodeId + '.address'), groupId).send({
                from: Config.get('public_key_registry.owner_address')
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}

function executeSetExpectedNodeToGroup() {
    readline.question('Type the id of node:\n', nodeId => {
        readline.question('Type the id of group:\n', groupId => {
            publicKeyRegistryContract.methods.setExpectedNodeToGroup(Config.get('public_key_registry.node.' + nodeId + '.address'), groupId).send({
                from: Config.get('public_key_registry.owner_address')
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}

function executeSetExpectedPublicKeyToActual() {
    readline.question('Type the id of group:\n', groupId => {
        publicKeyRegistryContract.methods.setExpectedPublicKeyToActual(groupId).send({
            from: Config.get('public_key_registry.owner_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}

function executeUpdateActualPublicKey() {
    readline.question('Type the id of node:\n', nodeId => {
        readline.question('Type the id of group:\n', groupId => {
            publicKeyRegistryContract.methods.updateActualPublicKey(groupId, web3.utils.toBN(Config.get('public_key_registry.group.' + groupId + '.actual_public_key_xx')), web3.utils.toBN(Config.get('public_key_registry.group.' + groupId + '.actual_public_key_xy')), web3.utils.toBN(Config.get('public_key_registry.group.' + groupId + '.actual_public_key_yx')), web3.utils.toBN(Config.get('public_key_registry.group.' + groupId + '.actual_public_key_yy'))).send({
                from: Config.get('public_key_registry.node.' + nodeId + '.address')
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}

function executeAddToExpectedPublicKey() {
    readline.question('Type the id of node:\n', nodeId => {
        readline.question('Type the id of group:\n', groupId => {
            publicKeyRegistryContract.methods.addToExpectedPublicKey(groupId, web3.utils.toBN(Config.get('public_key_registry.node.' + nodeId + '.public_key_xx')), web3.utils.toBN(Config.get('public_key_registry.node.' + nodeId + '.public_key_xy')), web3.utils.toBN(Config.get('public_key_registry.node.' + nodeId + '.public_key_yx')), web3.utils.toBN(Config.get('public_key_registry.node.' + nodeId + '.public_key_yy'))).send({
                from: Config.get('public_key_registry.node.' + nodeId + '.address')
            }).then(receipt => {
                console.log(receipt)
            })
            readline.close()
        })
    })
}
