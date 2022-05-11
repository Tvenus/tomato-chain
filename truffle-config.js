const HDWalletProvider = require("@truffle/hdwallet-provider");
const keys = require("./keys.json");

module.exports = {
  contracts_build_directory: "./public/contracts",
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider({
          mnemonic: {
            phrase: keys.MNEMONIC,
          },
          providerOrUrl: `wss://eth-ropsten.alchemyapi.io/v2/HNRUizi2ibk27NnsTF0XF8o-qSK0Fxyv`,
          addressIndex: 0,
        }),
      network_id: 3,
      gas: 5500000, // Gas Limit, How much gas we are willing to spent
      // gasPrice: 43162694779, // how much we are willing to spent for unit of gas
      gasPrice: 100000000000, // how much we are willing to spent for unit of gas
      confirmations: 2, // number of blocks to wait between deployment
      timeoutBlocks: 400, // number of blocks before deployment times out
    },
  },
  compilers: {
    solc: {
      version: "0.8.4",
    },
  },
};

//contract address 0xdEFABEF2e5c082A10Ff09f976A66Ec3119e12968

// account 0x195E34106DA1FCd4c900047B71b9812c7F027D04