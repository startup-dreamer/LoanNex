// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LoanNexNFT.sol";

contract LoanNex is Ownable, ERC1155Holder {
    error notEnoughFunds();
    error requirementsNotFull();

    event LenderOfferCreated(
        uint256 indexed lenderRegistryId_,
        address indexed _owner,
        address lendingToken,
        uint apr,
        uint lendingAmount
    );
    event LenderOfferDeleted(uint256 indexed lenderRegistryId_, address indexed _owner);
    event CollateralOfferCreated(
        uint256 indexed lenderRegistryId_,
        address indexed _owner,
        address lendingToken,
        uint apr,
        uint lendingAmount
    );
    event CollateralOfferDeleted(uint256 indexed lenderRegistryId_, address indexed _owner);
    event LoanAccepted(
        uint256 newId,
        address indexed lendingToken,
        address[] indexed collateralTokens
    );

    uint256 constant COUNTDOWN_PERIOD = 12 hours;
    
    // Id of the Lender Offer ID
    uint256 public lenderRegistryId;
    // Id of the Collateral Offer ID
    uint256 public lastCollateralOfferId;
    uint256 public LOAN_ID;
    // OWNERSHIP CONTRACT
    address NFT_CONTRACT;
    // Id count of the ownership NFT minted
    uint32 NFT_ID;

    bool private initialized;



    // Lender & Collateral struct is the same right now, will be one  --> struct OfferInfo {}
    struct LenderOInfo {
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

    struct CollateralOInfo {
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

    struct LoanInfo {
        uint32 collateralOwnerID;
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

    // Lender ID => All Info About the Offer
    mapping(uint256 => LenderOInfo) internal LendersOffers;
    // Collateral ID => All Info About the Collateral
    mapping(uint256 => CollateralOInfo) internal CollateralOffers;
    // Loan ID => All Info about the Loan
    mapping(uint256 => LoanInfo) internal Loans;

    // NFT ID => Loan ID
    mapping(uint256 => uint256) public loansByNft;
    // NFT ID => CLAIMEABLE DEBT
    mapping(uint256 => uint256) public claimeableDebt;


    constructor() {
    }

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
    function createLenderOption(
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
            timelap_ >= 1 days &&
            timelap_ <= 365 days &&
            wantedCollateralTokens_.length == wantedCollateralAmount_.length &&
            lenderAmount_ != 0 &&
            paymentCount_ <= 50 &&
            paymentCount_ <= lenderAmount_ &&
            whitelist_.length <= 2 && 
            interest_ <= 10000,
            "Invalid lender option parameters"
        );

        if (lenderToken_ == address(0x0)) {
            // If the lender's token is XDR (address(0x0)), check if the transaction value is greater than or equal to the lender amount
            require(msg.value >= lenderAmount_);
        } else {
            // If the lender's token is not XDR, transfer the lender amount from the sender to the contract address
            IERC20 _landerToken = IERC20(lenderToken_);
            // Check Taxable Tokens --> If it's taxable token, revert
            uint256 balanceBefore = _landerToken.balanceOf(address(this));
            bool success = _landerToken.transferFrom(
                msg.sender,
                address(this),
                lenderAmount_
            );
            require(success, "Tx failed");
            uint256 balanceAfter = _landerToken.balanceOf(address(this));
            require(
                (balanceAfter - balanceBefore) == lenderAmount_,
                "Taxable Token"
            );
        }

        lenderRegistryId++;
        // Create a new LenderOInfo struct with the provided information
        LenderOInfo memory lastLender = LenderOInfo({
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
        emit LenderOfferCreated(
            lenderRegistryId,
            msg.sender,
            lenderToken_,
            interest_,
            lenderAmount_
        );
    }

    // Cancel Lender Offer
    function cancelLenderOffer(uint256 lenderRegistryId_) public {
        LenderOInfo memory lenderInfo = LendersOffers[lenderRegistryId_];
        if (lenderInfo.owner != msg.sender) {
            revert();
        }
        delete LendersOffers[lenderRegistryId_];
        if (lenderInfo.lenderToken != address(0x0)) {
            IERC20 _landerToken = IERC20(lenderInfo.lenderToken);
            bool success = _landerToken.transfer(
                msg.sender,
                lenderInfo.lenderAmount
            );
            require(success);
        } else {
            (bool success, ) = msg.sender.call{value: lenderInfo.lenderAmount}(
                ""
            );
            require(success, "Transaction failed");
        }
        emit LenderOfferDeleted(lenderRegistryId_, msg.sender);
    }

    // User A offers to provide some collateral, such as a valuable asset, to User B in exchange for the loan. User B agrees to lend the money to User A under the condition that User A puts up the collateral as security for the loan.

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
            timelap_ >= 1 days &&
            timelap_ <= 365 days &&
            collateralTokens_.length == collateralAmount_.length &&
            wantedlenderAmount_ != 0 &&
            paymentCount_ <= 50 &&
            paymentCount_ <= wantedlenderAmount_ &&
            whitelist_.length <= 2 && 
            interest_ <= 10000,
            "Invalid collateral offer parameters"
        );
        
        uint256 amountWei;
        for (uint256 i; i < collateralTokens_.length; i++) {
            if (collateralTokens_[i] == address(0x0)) {
                // Check if the collateral token is XDR (address(0x0)) and Sum up the collateral amount in Wei
                amountWei += collateralAmount_[i];
            } else {
                // If the collateral token is not XDR, transfer the collateral amount from the sender to the contract address
                IERC20 collateralToken = IERC20(collateralTokens_[i]);
                uint balanceBefore = collateralToken.balanceOf(address(this));
                bool success = collateralToken.transferFrom(
                    msg.sender,
                    address(this),
                    collateralAmount_[i]
                );
                require(success);
                uint balanceAfter = collateralToken.balanceOf(address(this));
                require(
                    (balanceAfter - balanceBefore) == collateralAmount_[i],
                    "Taxable Token"
                );
            }
        }
        // Check if the transaction value is greater than or equal to the total collateral amount in Wei
        require(msg.value >= amountWei, "Not Enough XDR");

        lastCollateralOfferId++;
        // Create a new CollateralOInfo struct with the provided information
        CollateralOInfo memory lastCollateral = CollateralOInfo({
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
            lastCollateralOfferId,
            msg.sender,
            requireLenderToken_,
            interest_,
            wantedlenderAmount_
        );
    }

    function cancelCollateralOffer(uint256 id_) public {
        CollateralOInfo memory collateralInfo = CollateralOffers[id_];
        require(collateralInfo.owner == msg.sender, "Sender is not the owner");
        delete CollateralOffers[id_]; // Deleting info before transfering anything
        // Iterate over the collateral tokens and transfer them back to the owner
        for (uint256 i; i < collateralInfo.collateralAmount.length; i++) {
            if (collateralInfo.collaterals[i] != address(0x0)) {
                IERC20 token = IERC20(collateralInfo.collaterals[i]);
                bool success = token.transfer(
                    msg.sender,
                    collateralInfo.collateralAmount[i]
                );
                require(success);
            } else {
                (bool success, ) = msg.sender.call{
                    value: collateralInfo.collateralAmount[i]
                }("");
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
        CollateralOInfo memory collateralInfo = CollateralOffers[id_];
        require(
            collateralInfo.owner != address(0x0),
            "Offer does not exists."
        );
        // Check if Whitelist exists and if the sender is whitelisted

        if (
            collateralInfo.whitelist.length > 0 &&
            (collateralInfo.whitelist[0] != msg.sender &&
                collateralInfo.whitelist[1] != msg.sender)
        ) {
            revert();
        }

        delete CollateralOffers[id_]; // Delete the collateral offer from the mapping

        // Send Tokens to Collateral Owner

        if (collateralInfo.requireLenderToken == address(0x0)) {
            require(
                msg.value >= collateralInfo.wantedlenderAmount,
                "Not Enough XDR"
            );
            (bool success, ) = collateralInfo.owner.call{
                value: collateralInfo.wantedlenderAmount
            }("");
            require(success, "Transaction Error");
        } else {
            IERC20 wantedToken = IERC20(collateralInfo.requireLenderToken);
            uint balanceBefore = wantedToken.balanceOf(collateralInfo.owner);
            bool success = wantedToken.transferFrom(
                msg.sender,
                collateralInfo.owner,
                collateralInfo.wantedlenderAmount
            );
            require(success, "Error");
            uint balanceAfter = wantedToken.balanceOf(collateralInfo.owner);
            require(
                (balanceAfter - balanceBefore) ==
                    collateralInfo.wantedlenderAmount,
                "Taxable Token"
            );
        }

        // Update States & Mint NFTS (ID % 2 == 0 = 'BORROWER' && ID % 2 == 1 = 'LENDER')
        NFT_ID += 2;
        LOAN_ID++;
        Ownerships ownershipContract = Ownerships(NFT_CONTRACT);
        for (uint256 i; i < 2; i++) {
            ownershipContract.mint();
            if (i == 0) {
                ownershipContract.transferFrom(
                    address(this),
                    msg.sender,
                    NFT_ID - 1
                );
                loansByNft[NFT_ID - 1] = LOAN_ID;
            } else {
                ownershipContract.transferFrom(
                    address(this),
                    collateralInfo.owner,
                    NFT_ID
                );
                loansByNft[NFT_ID] = LOAN_ID;
            }
            // Transfer to new owners
        }
        // Save Loan Info
        uint256 paymentPerTime;
     
            // Calculate payment per time based on payment count and interest
          paymentPerTime =
                ((collateralInfo.wantedlenderAmount /
                    collateralInfo.paymentCount) *
                    (1000 + collateralInfo.interest)) /
                1000;
      
        // Calculate Deadline
        uint256 globalDeadline = (collateralInfo.paymentCount *
            collateralInfo.timelap) + block.timestamp;
        uint256 nextDeadline = block.timestamp + collateralInfo.timelap;

        // Save Mapping Info
        Loans[LOAN_ID] = LoanInfo({
            collateralOwnerID: NFT_ID,
            lenderOwnerId: NFT_ID - 1,
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
        emit LoanAccepted(
            LOAN_ID,
            collateralInfo.requireLenderToken,
            collateralInfo.collaterals
        );
    }

    function acceptLenderOffer(uint256 lenderRegistryId_) public payable {
        LenderOInfo memory lenderInfo = LendersOffers[lenderRegistryId_];
        require(lenderInfo.owner != address(0x0), "Offer Expired");
        // Check Whitelist
        if (
            lenderInfo.whitelist.length > 0 &&
            (lenderInfo.whitelist[0] != msg.sender &&
                lenderInfo.whitelist[1] != msg.sender)
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
                IERC20 wantedToken = IERC20(
                    lenderInfo.wantedCollateralTokens[i]
                );
                uint balanceBefore = wantedToken.balanceOf(address(this));
                bool success = wantedToken.transferFrom(
                    msg.sender,
                    address(this),
                    lenderInfo.wantedCollateralAmount[i]
                );
                require(success);
                uint balanceAfter = wantedToken.balanceOf(address(this));
                require(
                    (balanceAfter - balanceBefore) ==
                        lenderInfo.wantedCollateralAmount[i],
                    "Taxable Token"
                );
            }
        }

        require(msg.value >= amountWei, "Not enough XDR");
        // Update States & Mint NFTS
        NFT_ID += 2;
        LOAN_ID++;
        Ownerships ownershipContract = Ownerships(NFT_CONTRACT);

        for (uint256 i; i < 2; i++) {
            ownershipContract.mint();
            if (i == 0) {
                ownershipContract.transferFrom(
                    address(this),
                    lenderInfo.owner,
                    NFT_ID - 1
                );
                loansByNft[NFT_ID - 1] = LOAN_ID;
            } else {
                ownershipContract.transferFrom(
                    address(this),
                    msg.sender,
                    NFT_ID
                );
                loansByNft[NFT_ID] = LOAN_ID;
            }
        }

       
          uint256  paymentPerTime =
                ((lenderInfo.lenderAmount / lenderInfo.paymentCount) *
                    (1000 + lenderInfo.interest)) /
                1000;
        
        // Calculate loan deadlines
        uint256 globalDeadline = (lenderInfo.paymentCount *
            lenderInfo.timelap) + block.timestamp;
        uint256 nextDeadline = block.timestamp + lenderInfo.timelap;
        // Store loan information in the mapping
        Loans[LOAN_ID] = LoanInfo({
            collateralOwnerID: NFT_ID,
            lenderOwnerId: NFT_ID - 1,
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
            (bool success, ) = msg.sender.call{
                value: lenderInfo.lenderAmount
            }("");
            require(success, "Transaction Error");
        } else {
            IERC20 lenderToken = IERC20(lenderInfo.lenderToken);
            bool success = lenderToken.transfer(
                msg.sender,
                lenderInfo.lenderAmount
            );
            require(success);
        }

        emit LenderOfferDeleted(lenderRegistryId_, msg.sender);
        emit LoanAccepted(
            LOAN_ID,
            lenderInfo.lenderToken,
            lenderInfo.wantedCollateralTokens
        );
    }

    function payDebt(uint256 lenderRegistryId_) public payable {
        LoanInfo memory loan = Loans[lenderRegistryId_];
        Ownerships ownerContract = Ownerships(NFT_CONTRACT);

        // Check conditions for valid debt payment
        // Revert the transaction if any condition fail

        // 1. Check if the loan final deadline has passed
        // 2. Check if the sender is the owner of the collateral associated with the loan
        // 3. Check if all payments have been made for the loan
        // 4. Check if the loan collateral has already been executed
        if (
            loan.deadline < block.timestamp ||
            ownerContract.ownerOf(loan.collateralOwnerID) != msg.sender ||
            loan.paymentsPaid == loan.paymentCount ||
            loan.executed == true
        ) {
            revert();
        }

        uint interestPerPayment = ((loan.paymentAmount * loan.paymentCount) - loan.lenderAmount) / loan.paymentCount;

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
            bool success = lenderToken.transferFrom(
                msg.sender,
                address(this),
                loan.paymentAmount
            );
            require(success);
        }
        // Update the claimable debt for the lender
        // Ensure the token transfer was successful
     
    }

    function claimCollateralasLender(uint256 lenderRegistryId_) public {
        LoanInfo memory loan = Loans[lenderRegistryId_];
        Ownerships ownerContract = Ownerships(NFT_CONTRACT);
        // 1. Check if the sender is the owner of the lender's NFT
        // 2. Check if the deadline for the next payment has passed
        // 3. Check if all payments have been made for the loan
        // 4. Check if the loan has already been executed
        if (
            ownerContract.ownerOf(loan.lenderOwnerId) != msg.sender ||
            loan.deadlineNext > block.timestamp ||
            loan.paymentCount == loan.paymentsPaid ||
            loan.executed == true
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
                // Check if the collateral token is XDR (address(0x0))
                // Sum up the collateral amount in Wei
                amountWei += loan.collateralAmount[i];
            } else {
                IERC20 token = IERC20(loan.collaterals[i]);
                bool success = token.transfer(
                    msg.sender,
                    loan.collateralAmount[i]
                );
                require(success);
            }
        }
        // Transfer the Wei amount to the lender's address
        if (amountWei > 0) {
            (bool success, ) = msg.sender.call{value: amountWei}("");
            require(success);
        }
    }

    function claimCollateralasBorrower(uint256 lenderRegistryId_) public {
        LoanInfo memory loan = Loans[lenderRegistryId_];
        Ownerships ownerContract = Ownerships(NFT_CONTRACT);
        // 1. Check if the sender is the owner of the borrowers's NFT
        // 2. Check if the paymenyCount is different than the paids
        // 3. Check if the loan has already been executed
        if (
            ownerContract.ownerOf(loan.collateralOwnerID) != msg.sender ||
            loan.paymentCount != loan.paymentsPaid ||
            loan.executed == true
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
                bool successF = token.transfer(
                    msg.sender,
                    loan.collateralAmount[i]
                );
                require(successF);
            }
        }
        // Transfer the Wei amount to the lender's address
        if (amountWei > 0) {
            (bool success, ) = msg.sender.call{value: amountWei}("");
            require(success);
        }
    }

    function claimDebt(uint lenderRegistryId_) public {
        LoanInfo memory LOAN_INFO = Loans[lenderRegistryId_];
        Ownerships ownerContract = Ownerships(NFT_CONTRACT);
        uint amount = claimeableDebt[LOAN_INFO.lenderOwnerId];

        // 1. Check if the sender is the owner of the lender's NFT
        // 2. Check if there is an amount available to claim
        if (
            ownerContract.ownerOf(LOAN_INFO.lenderOwnerId) != msg.sender ||
            amount == 0
        ) {
            revert();
        }
        // Delete the claimable debt amount for the lender
        delete claimeableDebt[LOAN_INFO.lenderOwnerId];
        LOAN_INFO.cooldown = block.timestamp + COUNTDOWN_PERIOD;
        Loans[lenderRegistryId_] = LOAN_INFO;
        
        if (LOAN_INFO.lenderToken == address(0x0)) {
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Transaction Failed");
        } else {
            IERC20 lenderToken = IERC20(LOAN_INFO.lenderToken);
            // Transfer the debt amount of the token to the lender's address
            bool success = lenderToken.transfer(msg.sender, amount);
            require(success);
        }
    }

    function setNFTContract(address _newAddress) public onlyInit {
        NFT_CONTRACT = _newAddress;
    }

    function getOfferLENDER_DATA(
        uint id_
    ) public view returns (LenderOInfo memory) {
        return LendersOffers[id_];
    }

    function getOfferCOLLATERAL_DATA(
        uint id_
    ) public view returns (CollateralOInfo memory) {
        return CollateralOffers[id_];
    }

    function getLOANS_DATA(uint id_) public view returns (LoanInfo memory) {
        return Loans[id_];
    }
}