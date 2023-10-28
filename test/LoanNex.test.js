const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LoanNex", function () {
  let LoanNex;
  let loanNex;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    LoanNex = await ethers.getContractFactory("LoanNex");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    loanNex = await LoanNex.deploy();
    await loanNex.deployed();
  });

  describe("createLenderOption", function () {
    it("Should create a lender option successfully", async function () {
      const lenderToken = addr1.address;
      const wantedCollateralTokens = [addr2.address];
      const wantedCollateralAmount = [100];
      const lenderAmount = 1000;
      const interest = 10;
      const timelap = 86400; // 1 day in seconds
      const paymentCount = 10;
      const whitelist = [addr2.address];

      await loanNex.createLenderOption(
        lenderToken,
        wantedCollateralTokens,
        wantedCollateralAmount,
        lenderAmount,
        interest,
        timelap,
        paymentCount,
        whitelist
      );

      const lenderOption = await loanNex.getOfferLENDER_DATA(1);

      expect(lenderOption.lenderToken).to.equal(lenderToken);
      expect(lenderOption.wantedCollateralTokens[0]).to.equal(wantedCollateralTokens[0]);
      expect(lenderOption.wantedCollateralAmount[0]).to.equal(wantedCollateralAmount[0]);
      expect(lenderOption.lenderAmount).to.equal(lenderAmount);
      expect(lenderOption.interest).to.equal(interest);
      expect(lenderOption.timelap).to.equal(timelap);
      expect(lenderOption.paymentCount).to.equal(paymentCount);
      expect(lenderOption.whitelist[0]).to.equal(whitelist[0]);
      expect(lenderOption.owner).to.equal(owner.address);
    });
  });

  describe("cancelLenderOffer", function () {
    it("Should cancel a lender offer successfully", async function () {
      // Add your test logic here
    });
  });

  describe("createCollateralOffer", function () {
    it("Should create a collateral offer successfully", async function () {
      // Add your test logic here
    });
  });

  describe("cancelCollateralOffer", function () {
    it("Should cancel a collateral offer successfully", async function () {
      // Add your test logic here
    });
  });

  describe("acceptCollateralOffer", function () {
    it("Should accept a collateral offer successfully", async function () {
      // Add your test logic here
    });
  });

  describe("acceptLenderOffer", function () {
    it("Should accept a lender offer successfully", async function () {
      // Add your test logic here
    });
  });

  describe("payDebt", function () {
    it("Should pay a debt successfully", async function () {
      // Add your test logic here
    });
  });

  describe("claimCollateralasLender", function () {
    it("Should claim a collateral as lender successfully", async function () {
      // Add your test logic here
    });
  });

  describe("claimCollateralasBorrower", function () {
    it("Should claim a collateral as borrower successfully", async function () {
      // Add your test logic here
    });
  });

  describe("claimDebt", function () {
    it("Should claim a debt successfully", async function () {
      // Add your test logic here
    });
  });
});