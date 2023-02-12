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
const signatureVerifierJson = Fs.readFileSync('./abi/SignatureVerifier.abi');
const signatureVerifierAbi = JSON.parse(signatureVerifierJson);
const signatureVerifierContract = new web3.eth.Contract(signatureVerifierAbi, Config.get('signature_verifier.contract_address'), {
    gas: Config.get('ethereum.gas'),
    gasPrice: Config.get('ethereum.gas_price')
})

console.log("The public key registry supports these functions:")
console.log("1. getOwner")
console.log("2. setG2Element")
console.log("3. setPublicKey")
console.log("4. verify")
readline.question('Type the index to execute the corresponding function, type something else to exit:\n', index => {
    switch (index) {
        case '1':
            executeGetOwner()
            break
        case '2':
            executeSetG2Element()
            break
        case '3':
            executeSetPublicKey()
            break
        case '4':
            executeVerify()
            break
        default:
            process.exit()
    }
})

function executeGetOwner() {
    signatureVerifierContract.methods.getOwner().call().then(result => {
        console.log(result)
    })
    readline.close()
}

function executeSetG2Element() {
    signatureVerifierContract.methods.setG2Element(web3.utils.toBN(Config.get('signature_verifier.g2_element_xx')), web3.utils.toBN(Config.get('signature_verifier.g2_element_xy')), web3.utils.toBN(Config.get('signature_verifier.g2_element_yx')), web3.utils.toBN(Config.get('signature_verifier.g2_element_yy'))).send({
        from: Config.get('signature_verifier.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeSetPublicKey() {
    signatureVerifierContract.methods.setPublicKey(web3.utils.toBN(Config.get('signature_verifier.public_key_xx')), web3.utils.toBN(Config.get('signature_verifier.public_key_xy')), web3.utils.toBN(Config.get('signature_verifier.public_key_yx')), web3.utils.toBN(Config.get('signature_verifier.public_key_yy'))).send({
        from: Config.get('signature_verifier.owner_address')
    }).then(receipt => {
        console.log(receipt)
    })
    readline.close()
}

function executeVerify() {
    readline.question('Type the id of ctx:\n', ctxId => {
        signatureVerifierContract.methods.verify(ctxId, web3.utils.toBN(Config.get('signature_verifier.message_hash_x')), web3.utils.toBN(Config.get('signature_verifier.message_hash_y')), web3.utils.toBN(Config.get('signature_verifier.signature_x')), web3.utils.toBN(Config.get('signature_verifier.signature_y'))).send({
            from: Config.get('signature_verifier.verifier_address')
        }).then(receipt => {
            console.log(receipt)
        })
        readline.close()
    })
}
