# Siwa DApp

This is the on-chain part of the blockchain oracle Siwa, implemented as smart contracts. You can deploy and test them, and run clients to interact with them.

## To start using Siwa DApp

Install [Node.js](https://nodejs.org/zh-cn/), [cnpm](https://npmmirror.com/), [Truffle](https://www.trufflesuite.com/truffle) and [Ganache](https://www.trufflesuite.com/ganache).

Clone this repository and install node modules.
```
git clone https://github.com/KofClubs/siwa-dapp.git
cd siwa-dapp/
cnpm install
```

Create a Ganache workspace based on `truffle-config.js`, test and deploy smart contracts.
```
truffle test
truffle migrate
```

Run `*-client.js` to interact with the corresponding smart contracts.
