require("@nomicfoundation/hardhat-toolbox");
const dotenv = require("dotenv");

dotenv.config();

module.exports = {
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    xdcTestnet: {
      url: 'https://erpc.apothem.network',
      accounts: ['c6b715d8e42367ccf6992b7a8c787ba4ed4c0b44c467b0af6fecc888a6023813'],
    },
    maticTestnet: {
      url: process.env.MATIC_TESTNET || "",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  }
};
