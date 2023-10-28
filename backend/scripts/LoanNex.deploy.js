const { ethers, run } = require("hardhat");

/**
 * Deploys the BorrowXCore contract with the specified parameters and verifies the contract.
 * @returns {Promise<void>}
 */

async function main() {
  const LoanNex = await ethers.getContractFactory("LoanNex");
  const LoanNexNFT = await ethers.getContractFactory("LoanNexNFT");
  const loanNex = await LoanNex.deploy();
  await loanNex.deployed();
  const loanNexNFT = await LoanNexNFT.deploy();
  await loanNexNFT.deployed();
  console.log('LoanNex is deployed to: ', loanNex.address);
  console.log('LoanNexNFT is deployed to: ', loanNexNFT.address);

  const tx = await loanNexNFT.setLoanNex(loanNex.address);
  await tx.wait();
  const tx1 = await loanNex.setNFTContract(loanNexNFT.address);
  await tx1.wait();
  console.log('Deployment Completed');

  // Verification script
  const address = loanNex.address;
  console.log(`Verifying contract at address ${address}...`);
  await run("verify:verify", {
    address,
    constructorArguments: [],
  });

  const address1 = loanNexNFT.address;
  console.log(`Verifying contract at address ${address1}...`);
  await run("verify:verify", {
    address1,
    constructorArguments: [],
  });
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

//   const { ethers } = require("hardhat");

// async function main() {
//   const options = {
//     gasPrice: 125 * 10 ** 9,
//     // Other transaction options...
//   };
  
//   const Debita = await ethers.getContractFactory("DebitaV1");
//   const loanNexNFT = await ethers.getContractFactory("loanNexNFT");
//   const loanNex = await Debita.deploy(options);
//   const loanNexNFT = await loanNexNFT.deploy(options);
//   console.log(loanNex.target, 'DEBITA');
//   console.log(loanNexNFT.target, 'loanNexNFT');

//   await loanNexNFT.setDebitaContract(loanNex.target, options);
//   await loanNex.setNFTContract(loanNexNFT.target, options);
//   console.log('FINISHED');

// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });