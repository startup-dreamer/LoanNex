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
      accounts: [''],
    },
    maticTestnet: {
      url: process.env.MATIC_TESTNET || "",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  }
};
