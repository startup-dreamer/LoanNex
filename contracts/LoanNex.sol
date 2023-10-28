// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LoanNexNFT.sol";

contract LoanNex is Ownable, ERC1155Holder {
    // Time period for the loan in seconds
    uint256 constant COUNTDOWN_PERIOD = 12 hours;

    // Counters
    uint256 public lenderRegistryId;
    uint256 public lastCollateralOfferId;
    uint256 public loanCounter;
    uint32 public nftCounter;

    // Address of the NFT Contract
    address public loanNexNFT;
    bool private initialized;

    // Lender Offer Information
    struct LenderOfferInfo {
        address lenderToken;
        address[] wantedCollateralTokens;
        uint256[] wantedCollateralAmount;
        uint256 lenderAmount;
        uint256 interest;
        uint256 timelap;
        uint256 paymentCount;
        address[] whitelist;
        address owner;
    }

    // Collateral Offer Information
    struct CollateralOfferInfo {
        address requireLenderToken;
        address[] collaterals;
        uint256[] collateralAmount;
        uint256 wantedlenderAmount;
        uint256 interest;
        uint256 timelap;
        uint256 paymentCount;
        address[] whitelist;
        address owner;
    }

    // Loan Information
    struct LoanInfo {
        uint32 collateralOwnerId;
        uint32 lenderOwnerId;
        address lenderToken;
        uint256 cooldown;
        uint256 lenderAmount;
        address[] collaterals;
        uint256[] collateralAmount;
        uint256 timelap;
        uint256 paymentCount;
        uint256 paymentsPaid;
        uint256 paymentAmount;
        uint256 deadline;
        uint256 deadlineNext;
        bool executed;
    }

    // Mappings
    mapping(uint256 => LenderOfferInfo) internal LendersOffers;
    mapping(uint256 => Collateral) internal CollateralOffers;
    mapping(uint256 => LoanInfo) internal Loans;
    mapping(uint256 => uint256) public loansByNft;
    mapping(uint256 => uint256) public claimeableDebt;

    // Events
    event LenderOfferCreated(
        uint256 indexed lenderRegistryId,
        address indexed owner,
        address lendingToken,
        uint256 apr,
        uint256 lendingAmount
    );
    event LenderOfferDeleted(uint256 indexed lenderRegistryId, address indexed owner);
    event CollateralOfferCreated(
        uint256 indexed lenderRegistryId,
        address indexed owner,
        address lendingToken,
        uint256 apr,
        uint256 lendingAmount
    );
    event CollateralOfferDeleted(uint256 indexed lenderRegistryId, address indexed owner);
    event LoanAccepted(uint256 newId, address indexed lendingToken, address[] indexed collateralTokens);

    constructor() {}

    modifier onlyInit() {
        require(msg.sender == owner() || initialized, "Not initialized");
        _;
        initialized = true;
    }

    /**
     * @dev Creates a lender option for offering a loan by the lender.
     * @param lenderToken_ The address of the token that the lender wants to lend.
     * @param wantedCollateralTokens_ An array of addresses representing the collateral tokens desired by the lender.
     * @param wantedCollateralAmount_ An array of corresponding amounts of the collateral tokens desired by the lender.
     * @param lenderAmount_ The amount of the lender's token to be lent.
     * @param interest_ The interest rate for the loan. 10 --> 1% && 1 --> 0.1%
     * @param timelap_ The time period for the loan in seconds.
     * @param paymentCount_ The number of payments expected from the borrower.
     * @param whitelist_ An array of whitelisted addresses.
     */
    function offerLenderLoan(
        address lenderToken_,
        address[] memory wantedCollateralTokens_,
        uint256[] memory wantedCollateralAmount_,
        uint256 lenderAmount_,
        uint256 interest_,
        uint256 timelap_,
        uint256 paymentCount_,
        address[] memory whitelist_
    ) public payable {
        require(
            timelap_ >= 1 days && timelap_ <= 365 days
                && wantedCollateralTokens_.length == wantedCollateralAmount_.length && lenderAmount_ != 0
                && paymentCount_ <= 50 && paymentCount_ <= lenderAmount_ && whitelist_.length <= 2 && interest_ <= 10000,
            "Invalid lender option parameters"
        );

        if (lenderToken_ == address(0x0)) {
            // If the lender's token is XDC (address(0x0)), check if the transaction value is greater than or equal to the lender amount
            require(msg.value >= lenderAmount_);
        } else {
            // If the lender's token is not XDC, transfer the lender amount from the sender to the contract address
            IERC20 _landerToken = IERC20(lenderToken_);
            // Check Taxable Tokens --> If it's taxable token, revert
            uint256 balanceBefore = _landerToken.balanceOf(address(this));
            bool success = _landerToken.transferFrom(msg.sender, address(this), lenderAmount_);
            require(success, "Tx failed");
            uint256 balanceAfter = _landerToken.balanceOf(address(this));
            require((balanceAfter - balanceBefore) == lenderAmount_, "Taxable Token");
        }

        lenderRegistryId++;
        // Create a new LenderOfferInfo struct with the provided information
        LenderOfferInfo memory lastLender = LenderOfferInfo({
            lenderToken: lenderToken_,
            wantedCollateralTokens: wantedCollateralTokens_,
            wantedCollateralAmount: wantedCollateralAmount_,
            lenderAmount: lenderAmount_,
            interest: interest_,
            timelap: timelap_,
            paymentCount: paymentCount_,
            whitelist: whitelist_,
            owner: msg.sender
        });
        LendersOffers[lenderRegistryId] = lastLender;
        emit LenderOfferCreated(lenderRegistryId, msg.sender, lenderToken_, interest_, lenderAmount_);
    }

    // Cancel Lender Offer
    function cancelLenderOffer(uint256 lenderRegistryId_) public {
        LenderOfferInfo memory lenderInfo = LendersOffers[lenderRegistryId_];
        if (lenderInfo.owner != msg.sender) {
            revert();
        }
        delete LendersOffers[lenderRegistryId_];
        if (lenderInfo.lenderToken != address(0x0)) {
            IERC20 _landerToken = IERC20(lenderInfo.lenderToken);
            bool success = _landerToken.transfer(msg.sender, lenderInfo.lenderAmount);
            require(success);
        } else {
            (bool success,) = msg.sender.call{value: lenderInfo.lenderAmount}("");
            require(success, "Transaction failed");
        }
        emit LenderOfferDeleted(lenderRegistryId_, msg.sender);
    }

    /**
     * @dev Creates a collateral offer for a loan by the borrower.
     * @param requireLenderToken_ The address of the token that the borrower wants to borrow.
     * @param collateralTokens_ An array of addresses representing the collateral tokens being offered.
     * @param collateralAmount_ An array of corresponding amounts of the collateral tokens being offered.
     * @param wantedlenderAmount_ The desired amount of the lender's token by the borrower.
     * @param interest_ The interest rate for the loan.  1 --> 0.1%
     * @param timelap_ The time period for the loan in seconds.
     * @param paymentCount_ The number of payments to be made by the borrower.
     * @param whitelist_ An array of whitelisted addresses.
     */

    function createCollateralOffer(
        address requireLenderToken_,
        address[] memory collateralTokens_,
        uint256[] memory collateralAmount_,
        uint256 wantedlenderAmount_,
        uint256 interest_,
        uint256 timelap_,
        uint256 paymentCount_,
        address[] memory whitelist_
    ) public payable {
        require(
            timelap_ >= 1 days && timelap_ <= 365 days && collateralTokens_.length == collateralAmount_.length
                && wantedlenderAmount_ != 0 && paymentCount_ <= 50 && paymentCount_ <= wantedlenderAmount_
                && whitelist_.length <= 2 && interest_ <= 10000,
            "Invalid collateral offer parameters"
        );

        uint256 amountWei;
        for (uint256 i; i < collateralTokens_.length; i++) {
            if (collateralTokens_[i] == address(0x0)) {
                // Check if the collateral token is XDC (address(0x0)) and Sum up the collateral amount in Wei
                amountWei += collateralAmount_[i];
            } else {
                // If the collateral token is not XDC, transfer the collateral amount from the sender to the contract address
                IERC20 collateralToken = IERC20(collateralTokens_[i]);
                uint256 balanceBefore = collateralToken.balanceOf(address(this));
                bool success = collateralToken.transferFrom(msg.sender, address(this), collateralAmount_[i]);
                require(success);
                uint256 balanceAfter = collateralToken.balanceOf(address(this));
                require((balanceAfter - balanceBefore) == collateralAmount_[i], "Taxable Token");
            }
        }
        // Check if the transaction value is greater than or equal to the total collateral amount in Wei
        require(msg.value >= amountWei, "Not Enough XDC");

        lastCollateralOfferId++;
        // Create a new Collateral struct with the provided information
        Collateral memory lastCollateral = Collateral({
            requireLenderToken: requireLenderToken_,
            collaterals: collateralTokens_,
            collateralAmount: collateralAmount_,
            wantedlenderAmount: wantedlenderAmount_,
            interest: interest_,
            timelap: timelap_,
            paymentCount: paymentCount_,
            whitelist: whitelist_,
            owner: msg.sender
        });
        CollateralOffers[lastCollateralOfferId] = lastCollateral;
        emit CollateralOfferCreated(
            lastCollateralOfferId, msg.sender, requireLenderToken_, interest_, wantedlenderAmount_
        );
    }

    function cancelCollateralOffer(uint256 id_) public {
        Collateral memory collateralInfo = CollateralOffers[id_];
        require(collateralInfo.owner == msg.sender, "Sender is not the owner");
        delete CollateralOffers[id_]; // Deleting info before transfering anything
        // Iterate over the collateral tokens and transfer them back to the owner
        for (uint256 i; i < collateralInfo.collateralAmount.length; i++) {
            if (collateralInfo.collaterals[i] != address(0x0)) {
                IERC20 token = IERC20(collateralInfo.collaterals[i]);
                bool success = token.transfer(msg.sender, collateralInfo.collateralAmount[i]);
                require(success);
            } else {
                (bool success,) = msg.sender.call{value: collateralInfo.collateralAmount[i]}("");
                require(success, "Transaction failed");
            }
        }
        emit CollateralOfferDeleted(id_, msg.sender);
    }

    /**
     * @dev Accepts a collateral offer and initiates a loan.
     * @param id_ The ID of the collateral offer to accept.
     */
    function acceptCollateralOffer(uint256 id_) public payable {
        Collateral memory collateralInfo = CollateralOffers[id_];
        require(collateralInfo.owner != address(0x0), "Offer does not exists.");
        // Check if Whitelist exists and if the sender is whitelisted

        if (
            collateralInfo.whitelist.length > 0
                && (collateralInfo.whitelist[0] != msg.sender && collateralInfo.whitelist[1] != msg.sender)
        ) {
            revert();
        }

        delete CollateralOffers[id_]; // Delete the collateral offer from the mapping

        // Send Tokens to Collateral Owner

        if (collateralInfo.requireLenderToken == address(0x0)) {
            require(msg.value >= collateralInfo.wantedlenderAmount, "Not Enough XDC");
            (bool success,) = collateralInfo.owner.call{value: collateralInfo.wantedlenderAmount}("");
            require(success, "Transaction Error");
        } else {
            IERC20 wantedToken = IERC20(collateralInfo.requireLenderToken);
            uint256 balanceBefore = wantedToken.balanceOf(collateralInfo.owner);
            bool success = wantedToken.transferFrom(msg.sender, collateralInfo.owner, collateralInfo.wantedlenderAmount);
            require(success, "Error");
            uint256 balanceAfter = wantedToken.balanceOf(collateralInfo.owner);
            require((balanceAfter - balanceBefore) == collateralInfo.wantedlenderAmount, "Taxable Token");
        }

        // Update States & Mint Nfts (Id % 2 == 0 = 'Borroer' && ID % 2 == 1 = 'Lender')
        nftCounter += 2;
        loanCounter++;
        LoanNexNFT loanNex = LoanNexNFT(loanNexNFT);
        for (uint256 i; i < 2; i++) {
            loanNex.mint();
            if (i == 0) {
                loanNex.transferFrom(address(this), msg.sender, nftCounter - 1);
                loansByNft[nftCounter - 1] = loanCounter;
            } else {
                loanNex.transferFrom(address(this), collateralInfo.owner, nftCounter);
                loansByNft[nftCounter] = loanCounter;
            }
            // Transfer to new owners
        }
        // Save Loan Info
        uint256 paymentPerTime;

        // Calculate payment per time based on payment count and interest
        paymentPerTime = (
            (collateralInfo.wantedlenderAmount / collateralInfo.paymentCount) * (1000 + collateralInfo.interest)
        ) / 1000;

        // Calculate Deadline
        uint256 globalDeadline = (collateralInfo.paymentCount * collateralInfo.timelap) + block.timestamp;
        uint256 nextDeadline = block.timestamp + collateralInfo.timelap;

        // Save Mapping Info
        Loans[loanCounter] = LoanInfo({
            collateralOwnerId: nftCounter,
            lenderOwnerId: nftCounter - 1,
            lenderToken: collateralInfo.requireLenderToken,
            cooldown: block.timestamp,
            lenderAmount: collateralInfo.wantedlenderAmount,
            collaterals: collateralInfo.collaterals,
            collateralAmount: collateralInfo.collateralAmount,
            timelap: collateralInfo.timelap,
            paymentCount: collateralInfo.paymentCount,
            paymentsPaid: 0,
            paymentAmount: paymentPerTime,
            deadline: globalDeadline,
            deadlineNext: nextDeadline,
            executed: false
        });
        emit CollateralOfferDeleted(id_, msg.sender);
        emit LoanAccepted(loanCounter, collateralInfo.requireLenderToken, collateralInfo.collaterals);
    }

    function acceptLenderOffer(uint256 lenderRegistryId_) public payable {
        LenderOfferInfo memory lenderInfo = LendersOffers[lenderRegistryId_];
        require(lenderInfo.owner != address(0x0), "Offer Expired");
        // Check Whitelist
        if (
            lenderInfo.whitelist.length > 0
                && (lenderInfo.whitelist[0] != msg.sender && lenderInfo.whitelist[1] != msg.sender)
        ) {
            revert();
        }

        delete LendersOffers[lenderRegistryId_];
        uint256 amountWei;

        // Send Collaterals to this contract
        for (uint256 i; i < lenderInfo.wantedCollateralTokens.length; i++) {
            if (lenderInfo.wantedCollateralTokens[i] == address(0x0)) {
                amountWei += lenderInfo.wantedCollateralAmount[i];
            } else {
                IERC20 wantedToken = IERC20(lenderInfo.wantedCollateralTokens[i]);
                uint256 balanceBefore = wantedToken.balanceOf(address(this));
                bool success = wantedToken.transferFrom(msg.sender, address(this), lenderInfo.wantedCollateralAmount[i]);
                require(success);
                uint256 balanceAfter = wantedToken.balanceOf(address(this));
                require((balanceAfter - balanceBefore) == lenderInfo.wantedCollateralAmount[i], "Taxable Token");
            }
        }

        require(msg.value >= amountWei, "Not enough XDC");
        // Update States & Mint NFTS
        nftCounter += 2;
        loanCounter++;
        LoanNexNFT loanNex = LoanNexNFT(loanNexNFT);

        for (uint256 i; i < 2; i++) {
            loanNex.mint();
            if (i == 0) {
                loanNex.transferFrom(address(this), lenderInfo.owner, nftCounter - 1);
                loansByNft[nftCounter - 1] = loanCounter;
            } else {
                loanNex.transferFrom(address(this), msg.sender, nftCounter);
                loansByNft[nftCounter] = loanCounter;
            }
        }

        uint256 paymentPerTime =
            ((lenderInfo.lenderAmount / lenderInfo.paymentCount) * (1000 + lenderInfo.interest)) / 1000;

        // Calculate loan deadlines
        uint256 globalDeadline = (lenderInfo.paymentCount * lenderInfo.timelap) + block.timestamp;
        uint256 nextDeadline = block.timestamp + lenderInfo.timelap;
        // Store loan information in the mapping
        Loans[loanCounter] = LoanInfo({
            collateralOwnerId: nftCounter,
            lenderOwnerId: nftCounter - 1,
            lenderToken: lenderInfo.lenderToken,
            cooldown: block.timestamp,
            lenderAmount: lenderInfo.lenderAmount,
            collaterals: lenderInfo.wantedCollateralTokens,
            collateralAmount: lenderInfo.wantedCollateralAmount,
            timelap: lenderInfo.timelap,
            paymentCount: lenderInfo.paymentCount,
            paymentsPaid: 0,
            paymentAmount: paymentPerTime,
            deadline: globalDeadline,
            deadlineNext: nextDeadline,
            executed: false
        });
        // Send Loan to the owner of the collateral
        if (lenderInfo.lenderToken == address(0x0)) {
            (bool success,) = msg.sender.call{value: lenderInfo.lenderAmount}("");
            require(success, "Transaction Error");
        } else {
            IERC20 lenderToken = IERC20(lenderInfo.lenderToken);
            bool success = lenderToken.transfer(msg.sender, lenderInfo.lenderAmount);
            require(success);
        }

        emit LenderOfferDeleted(lenderRegistryId_, msg.sender);
        emit LoanAccepted(loanCounter, lenderInfo.lenderToken, lenderInfo.wantedCollateralTokens);
    }

    function payDebt(uint256 lenderRegistryId_) public payable {
        LoanInfo memory loan = Loans[lenderRegistryId_];
        LoanNexNFT ownerContract = LoanNexNFT(loanNexNFT);

        // Check conditions for valid debt payment
        // Revert the transaction if any condition fail
        if (
            loan.deadline < block.timestamp || ownerContract.ownerOf(loan.collateralOwnerId) != msg.sender
                || loan.paymentsPaid == loan.paymentCount || loan.executed == true
        ) {
            revert();
        }

        uint256 interestPerPayment = ((loan.paymentAmount * loan.paymentCount) - loan.lenderAmount) / loan.paymentCount;

        // Increment the number of payments made
        loan.paymentsPaid += 1;
        // Update the deadline for the next payment
        loan.deadlineNext += loan.timelap;
        Loans[lenderRegistryId_] = loan;
        claimeableDebt[loan.lenderOwnerId] += loan.paymentAmount;

        if (loan.lenderToken == address(0x0)) {
            require(msg.value >= loan.paymentAmount);
        } else {
            IERC20 lenderToken = IERC20(loan.lenderToken);
            bool success = lenderToken.transferFrom(msg.sender, address(this), loan.paymentAmount);
            require(success);
        }
        // Update the claimable debt for the lender
        // Ensure the token transfer was successful
    }

    function claimCollateralasLender(uint256 lenderRegistryId_) public {
        LoanInfo memory loan = Loans[lenderRegistryId_];
        LoanNexNFT ownerContract = LoanNexNFT(loanNexNFT);
        if (
            ownerContract.ownerOf(loan.lenderOwnerId) != msg.sender || loan.deadlineNext > block.timestamp
                || loan.paymentCount == loan.paymentsPaid || loan.executed == true
        ) {
            revert();
        }
        // Mark the loan as executed
        loan.executed = true;
        Loans[lenderRegistryId_] = loan;
        uint256 amountWei;

        // Iterate over the collateralTokens and collateralAmount arrays in the loan
        for (uint256 i; i < loan.collaterals.length; i++) {
            if (loan.collaterals[i] == address(0x0)) {
                // Check if the collateral token is XDC (address(0x0))
                // Sum up the collateral amount in Wei
                amountWei += loan.collateralAmount[i];
            } else {
                IERC20 token = IERC20(loan.collaterals[i]);
                bool success = token.transfer(msg.sender, loan.collateralAmount[i]);
                require(success);
            }
        }
        // Transfer the Wei amount to the lender's address
        if (amountWei > 0) {
            (bool success,) = msg.sender.call{value: amountWei}("");
            require(success);
        }
    }

    function claimCollateralasBorrower(uint256 lenderRegistryId_) public {
        LoanInfo memory loan = Loans[lenderRegistryId_];
        LoanNexNFT ownerContract = LoanNexNFT(loanNexNFT);
        if (
            ownerContract.ownerOf(loan.collateralOwnerId) != msg.sender || loan.paymentCount != loan.paymentsPaid
                || loan.executed == true
        ) {
            revert();
        }

        loan.executed = true;
        uint256 amountWei;
        Loans[lenderRegistryId_] = loan;

        for (uint256 i; i < loan.collaterals.length; i++) {
            if (loan.collaterals[i] == address(0x0)) {
                amountWei += loan.collateralAmount[i];
            } else {
                IERC20 token = IERC20(loan.collaterals[i]);
                // Transfer the Wei amount to the lender's address
                bool successF = token.transfer(msg.sender, loan.collateralAmount[i]);
                require(successF);
            }
        }
        // Transfer the Wei amount to the lender's address
        if (amountWei > 0) {
            (bool success,) = msg.sender.call{value: amountWei}("");
            require(success);
        }
    }

    function claimDebt(uint256 lenderRegistryId_) public {
        LoanInfo memory LOAN_INFO = Loans[lenderRegistryId_];
        LoanNexNFT ownerContract = LoanNexNFT(loanNexNFT);
        uint256 amount = claimeableDebt[LOAN_INFO.lenderOwnerId];

        // 1. Check if the sender is the owner of the lender's NFT
        // 2. Check if there is an amount available to claim
        if (ownerContract.ownerOf(LOAN_INFO.lenderOwnerId) != msg.sender || amount == 0) {
            revert();
        }
        // Delete the claimable debt amount for the lender
        delete claimeableDebt[LOAN_INFO.lenderOwnerId];
        LOAN_INFO.cooldown = block.timestamp + COUNTDOWN_PERIOD;
        Loans[lenderRegistryId_] = LOAN_INFO;

        if (LOAN_INFO.lenderToken == address(0x0)) {
            (bool success,) = msg.sender.call{value: amount}("");
            require(success, "Transaction Failed");
        } else {
            IERC20 lenderToken = IERC20(LOAN_INFO.lenderToken);
            // Transfer the debt amount of the token to the lender's address
            bool success = lenderToken.transfer(msg.sender, amount);
            require(success);
        }
    }

    function setNFTContract(address _newAddress) public onlyInit {
        loanNexNFT = _newAddress;
    }

    function getOfferLenderData(uint256 id_) public view returns (LenderOfferInfo memory) {
        return LendersOffers[id_];
    }

    function getOfferCollateralData(uint256 id_) public view returns (Collateral memory) {
        return CollateralOffers[id_];
    }

    function getLoansData(uint256 id_) public view returns (LoanInfo memory) {
        return Loans[id_];
    }
}
