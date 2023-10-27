pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/utils/Base64.sol";

// interface ILoanNex {
//     struct LoanInfo {
//         uint32 collateralOwnerID;
//         uint32 LenderOwnerId;
//         address LenderToken;
//         uint256 cooldown;
//         uint256 LenderAmount;
//         address[] collaterals;
//         uint256[] collateralAmount;
//         uint256 timelap;
//         uint256 paymentCount;
//         uint256 paymentsPaid;
//         uint256 paymentAmount;
//         uint256 deadline;
//         uint256 deadlineNext;
//         bool executed;
//     }

//     function getLOANS_DATA(uint _id) external view returns (LoanInfo memory);

//     function loansByNFt(uint _id) external view returns (uint);
// }

contract LoanNexNFT is ERC721Enumerable {
//     uint id = 0;
//     address deployer;
//     address LoanNex;
    
//     bool private initialized;

//     constructor() ERC721("Debita Ownerships", "DebitaOwnerships") {
//         deployer = msg.sender;
//     }

//     modifier onlyContract() {
//         require(msg.sender == LoanNex);
//         _;
//     }

//     modifier onlyDeployer() {
//         require(msg.sender == deployer && !initialized);
//         _;
//     }


//     function mint() public onlyContract {
//         id++;
//         _mint(msg.sender, id);
//     }

//     function setLoanNex(address LoanNex_) public onlyDeployer {
//         LoanNex = LoanNex_;
//         initialized = true;
//     }

//     function toString(uint value) private pure returns (string memory) {
//         if (value == 0) {
//             return "0";
//         }
//         uint temp = value;
//         uint digits;
//         while (temp != 0) {
//             digits++;
//             temp /= 10;
//         }
//         bytes memory buffer = new bytes(digits);
//         while (value != 0) {
//             digits -= 1;
//             buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
//             value /= 10;
//         }
//         return string(buffer);
//     }

//     function buildImage(
//         uint _id,
//         string[2] memory collateralNames,
//         string[2] memory collateralAmounts,
//         string memory lenderName,
//         string memory lenderAmount,
//         string memory status,
//         string memory _type
//     ) private pure returns (string memory) {
//         return
//             Base64.encode(
//                 bytes(
//                     string(
//                         abi.encodePacked(
//                             '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg" fill="none"> <style> * {font-family: Helvetica; }</style> <rect id="svg_36" height="500.706" width="500.706" y="3.29808" x="1.64699" stroke-width="3" stroke="#2d2d2d" fill="#252323"/> <g filter="url(#filter0_d_52_741)"> <text transform="matrix(1.22578 0 0 1.3603 -108.582 -34.4985)" stroke="#2d2d2d" font-weight="900" text-anchor="start"  font-size="30" id="svg_22" y="119.63608" x="361.99993" stroke-width="0" fill="#705BDC">f</text> <text transform="matrix(1.22578 0 0 1.3603 -108.582 -34.4985)" stroke="#2d2d2d" font-weight="900" text-anchor="start"  font-size="36" id="svg_22" y="119.63608" x="372.99993" stroke-width="0" fill="#705BDC">NFT</text> <path d="M63.1817 127.125H43V67.4114H63.3484C69.0749 67.4114 74.0045 68.6068 78.1372 70.9977C82.2699 73.3692 85.4482 76.7806 87.6721 81.2319C89.9145 85.6832 91.0357 91.0093 91.0357 97.21C91.0357 103.43 89.9145 108.776 87.6721 113.247C85.4482 117.717 82.2514 121.148 78.0816 123.539C73.9303 125.93 68.9637 127.125 63.1817 127.125ZM55.0367 116.308H62.6813C66.2395 116.308 69.2324 115.647 71.6601 114.325C74.1064 112.984 75.9411 110.914 77.1643 108.115C78.4059 105.296 79.0268 101.661 79.0268 97.21C79.0268 92.7976 78.4059 89.1918 77.1643 86.3927C75.9411 83.5936 74.1157 81.5332 71.688 80.2114C69.2602 78.8896 66.2672 78.2287 62.7091 78.2287H55.0367V116.308ZM119.189 128C114.796 128 111.016 127.067 107.847 125.201C104.696 123.315 102.269 120.652 100.564 117.212C98.8586 113.752 98.0061 109.66 98.0061 104.937C98.0061 100.33 98.8586 96.2867 100.564 92.8073C102.269 89.3279 104.668 86.6163 107.763 84.6725C110.877 82.7286 114.528 81.7567 118.716 81.7567C121.533 81.7567 124.155 82.2329 126.583 83.1855C129.029 84.1184 131.16 85.5277 132.976 87.4132C134.811 89.2987 136.238 91.6702 137.257 94.5276C138.277 97.3655 138.786 100.689 138.786 104.499V107.911H102.732V100.213H127.639C127.639 98.4249 127.269 96.8407 126.527 95.4606C125.786 94.0805 124.758 93.0017 123.442 92.2242C122.145 91.4272 120.634 91.0287 118.911 91.0287C117.113 91.0287 115.519 91.4661 114.129 92.3408C112.758 93.1961 111.683 94.3526 110.905 95.8105C110.126 97.2489 109.728 98.8526 109.709 100.621V107.94C109.709 110.156 110.098 112.07 110.877 113.684C111.674 115.297 112.795 116.541 114.24 117.416C115.686 118.291 117.4 118.728 119.383 118.728C120.699 118.728 121.903 118.534 122.997 118.145C124.091 117.756 125.026 117.173 125.804 116.395C126.583 115.618 127.176 114.665 127.583 113.538L138.536 114.296C137.98 117.056 136.841 119.467 135.117 121.527C133.412 123.568 131.207 125.162 128.501 126.309C125.814 127.436 122.71 128 119.189 128ZM131.976 67.4114V74.1467H104.9V67.4114H131.976ZM146.737 127.125V67.4114H158.579V89.8625H158.94C159.459 88.6573 160.21 87.4327 161.192 86.1886C162.193 84.9251 163.49 83.8755 165.084 83.0396C166.696 82.1844 168.698 81.7567 171.089 81.7567C174.202 81.7567 177.074 82.612 179.706 84.3226C182.337 86.0137 184.441 88.5698 186.016 91.9909C187.591 95.3926 188.379 99.6593 188.379 104.791C188.379 109.787 187.61 114.005 186.071 117.445C184.552 120.866 182.476 123.461 179.845 125.23C177.232 126.98 174.303 127.854 171.06 127.854C168.762 127.854 166.807 127.456 165.195 126.659C163.601 125.862 162.295 124.861 161.275 123.656C160.256 122.431 159.478 121.197 158.94 119.953H158.412V127.125H146.737ZM158.329 104.733C158.329 107.396 158.681 109.718 159.385 111.701C160.089 113.684 161.109 115.229 162.442 116.337C163.777 117.426 165.399 117.97 167.308 117.97C169.235 117.97 170.865 117.416 172.2 116.308C173.535 115.181 174.545 113.626 175.23 111.643C175.934 109.641 176.286 107.337 176.286 104.733C176.286 102.147 175.943 99.8731 175.258 97.9098C174.572 95.9466 173.562 94.4109 172.228 93.303C170.894 92.195 169.254 91.641 167.308 91.641C165.38 91.641 163.75 92.1756 162.415 93.2447C161.099 94.3138 160.089 95.83 159.385 97.7932C158.681 99.7565 158.329 102.07 158.329 104.733ZM196.281 127.125V82.3398H208.123V127.125H196.281ZM202.229 76.5668C200.469 76.5668 198.959 75.9545 197.698 74.7299C196.457 73.4858 195.835 71.9988 195.835 70.2688C195.835 68.5582 196.457 67.0907 197.698 65.8661C198.959 64.622 200.469 64 202.229 64C203.99 64 205.491 64.622 206.733 65.8661C207.993 67.0907 208.623 68.5582 208.623 70.2688C208.623 71.9988 207.993 73.4858 206.733 74.7299C205.491 75.9545 203.99 76.5668 202.229 76.5668ZM240.32 82.3398V91.6702H214.607V82.3398H240.32ZM220.444 71.61H232.287V113.363C232.287 114.51 232.453 115.404 232.787 116.046C233.12 116.668 233.584 117.105 234.177 117.358C234.788 117.61 235.492 117.737 236.289 117.737C236.846 117.737 237.401 117.688 237.957 117.591C238.513 117.474 238.94 117.387 239.236 117.329L241.099 126.571C240.505 126.766 239.671 126.989 238.597 127.242C237.522 127.514 236.215 127.679 234.677 127.738C231.823 127.854 229.321 127.456 227.172 126.542C225.04 125.629 223.381 124.21 222.195 122.285C221.009 120.361 220.425 117.931 220.444 114.996V71.61ZM260.21 127.971C257.486 127.971 255.058 127.475 252.927 126.484C250.795 125.473 249.109 123.986 247.867 122.023C246.644 120.04 246.033 117.571 246.033 114.617C246.033 112.129 246.468 110.039 247.339 108.348C248.21 106.657 249.396 105.296 250.898 104.266C252.398 103.236 254.103 102.458 256.013 101.934C257.94 101.409 259.959 101.039 262.072 100.826C264.556 100.553 266.557 100.301 268.077 100.067C269.596 99.8148 270.699 99.4454 271.385 98.9595C272.07 98.4735 272.413 97.7543 272.413 96.8019V96.6269C272.413 94.7803 271.857 93.3516 270.746 92.3408C269.652 91.33 268.095 90.8247 266.075 90.8247C263.944 90.8247 262.248 91.3203 260.988 92.3116C259.728 93.2835 258.894 94.5081 258.486 95.9855L247.534 95.0524C248.09 92.3311 249.183 89.979 250.814 87.9964C252.445 85.9942 254.548 84.4586 257.124 83.3896C259.719 82.301 262.721 81.7567 266.131 81.7567C268.503 81.7567 270.773 82.0483 272.941 82.6315C275.129 83.2146 277.065 84.1184 278.751 85.3431C280.456 86.5677 281.8 88.1422 282.782 90.0666C283.764 91.9714 284.255 94.2555 284.255 96.9185V127.125H273.025V120.915H272.692C272.006 122.314 271.089 123.549 269.939 124.618C268.79 125.667 267.409 126.494 265.798 127.096C264.185 127.679 262.323 127.971 260.21 127.971ZM263.601 119.399C265.344 119.399 266.882 119.039 268.216 118.32C269.55 117.581 270.597 116.59 271.357 115.346C272.117 114.102 272.497 112.693 272.497 111.118V106.365C272.126 106.618 271.616 106.851 270.968 107.065C270.338 107.26 269.624 107.444 268.827 107.619C268.03 107.775 267.233 107.92 266.436 108.057C265.639 108.173 264.917 108.28 264.269 108.377C262.878 108.591 261.664 108.931 260.627 109.398C259.589 109.864 258.783 110.496 258.208 111.293C257.634 112.07 257.346 113.042 257.346 114.209C257.346 115.9 257.93 117.192 259.098 118.087C260.284 118.961 261.785 119.399 263.601 119.399ZM300.365 127.883C298.53 127.883 296.955 127.203 295.639 125.842C294.342 124.462 293.693 122.81 293.693 120.886C293.693 118.981 294.342 117.348 295.639 115.987C296.955 114.627 298.53 113.946 300.365 113.946C302.144 113.946 303.7 114.627 305.035 115.987C306.369 117.348 307.036 118.981 307.036 120.886C307.036 122.169 306.721 123.345 306.091 124.414C305.479 125.463 304.673 126.309 303.673 126.95C302.672 127.572 301.569 127.883 300.365 127.883Z" fill="url(#paint0_linear_1295_3)"/> <mask id="path-2-inside-1_1295_3" fill="white"> <path d="M14 0H460.915V167H14V0Z"/> </mask> <path d="M460.915 166.051H14V167.949H460.915V166.051Z" fill="#242424" mask="url(#path-2-inside-1_1295_3)"/> </g> <defs>  <feFlood flood-opacity="0" result="BackgroundImageFix"/> <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/> <feOffset dy="13.5749"/> <feGaussianBlur stdDeviation="6.78745"/> <feComposite in2="hardAlpha" operator="out"/> <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/> <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow_1295_3"/> <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow_1295_3" result="shape"/>  <linearGradient id="paint0_linear_1295_3" x1="48.6319" y1="100.851" x2="317.254" y2="100.851" gradientUnits="userSpaceOnUse"> <stop stop-color="#D75071"/> <stop offset="1" stop-color="#705BDC"/> </linearGradient> </defs>',
//                             string(
//                                 abi.encodePacked(
//                                     ' <rect stroke="#2d2d2d" id="svg_10" height="75.07359" width="144.73118" y="157.83511" x="19.88808" stroke-width="3" fill="none"/> <text transform="matrix(0.653316 0 0 0.684165 17.3342 50.9147)" stroke="#2d2d2d" text-anchor="start"  font-size="30" id="svg_16" y="194.99114" x="19.38732" stroke-width="0" fill="#5A5A5A">Type</text> <text  text-anchor="start"  font-size="26" id="svg_17" y="220.04546" x="30.68199" stroke-width="0" stroke="#2d2d2d" fill="#848484">',
//                                     _type,
//                                     '</text> <rect stroke="#2d2d2d" id="svg_19" height="75.07359" width="144.73118" y="158.06586" x="175.39863" stroke-width="3" fill="none"/> <rect stroke="#2d2d2d" id="svg_20" height="75.07359" width="144.73118" y="158.56586" x="332.05246" stroke-width="3" fill="none"/>  <text style="cursor: move;"  text-anchor="start"  font-size="30" id="svg_23" y="219.04546" x="187.34866" stroke-width="0" stroke="#2d2d2d" fill="#DBB2E9" font-weight="900">',
//                                     status,
//                                     '</text> <text transform="matrix(0.653316 0 0 0.684165 17.3342 50.9147)" stroke="#2d2d2d"  text-anchor="start"  font-size="30" id="svg_24" y="195.08483" x="259.18957" stroke-width="0" fill="#5A5A5A">Status</text> <text style="cursor: move;" transform="matrix(0.653316 0 0 0.684165 17.3342 50.9147)" stroke="#2d2d2d"  text-anchor="start"  font-size="30" id="svg_25" y="196.30286" x="496.44074" stroke-width="0" fill="#5A5A5A">Loan ID</text>'
//                                 )
//                             ),
//                             string(
//                                 abi.encodePacked(
//                                     '<text style="cursor: move;" stroke="#2d2d2d" text-anchor="start"  font-size="30" id="svg_27" y="219.04546" x="343.58673" stroke-width="0" fill="#848484">',
//                                     toString(_id),
//                                     '</text> <rect stroke="#2d2d2d" id="svg_28" height="88.15051" width="455.43879" y="247.83757" x="19.67837" stroke-width="3" fill="none"/> <text transform="matrix(0.653316 0 0 0.684165 17.3342 50.9147)" stroke="#2d2d2d" text-anchor="start"  font-size="30" id="svg_29" y="327.66268" x="21.74217" stroke-width="0" fill="#5A5A5A">Collateral</text> <text text-anchor="start"  font-size="30" id="svg_30" y="315.43008" x="31.45122" stroke-width="0" stroke="#2d2d2d" fill="#848484" >',
//                                     collateralNames[0],
//                                     collateralNames[1],
//                                     '</text> <text text-anchor="start"  font-size="30" id="svg_31" y="316.19931" x="300.0666" stroke-width="0" stroke="#2d2d2d" fill="#AFAFAF" font-weight="900">',
//                                     (collateralAmounts[0]),
//                                     (collateralAmounts[1]),
//                                     "</text>"
//                                 )
//                             ),
//                             '<rect stroke="#2d2d2d" id="svg_32" height="88.15051" width="455.43879" y="347.83757" x="20.26316" stroke-width="3" fill="none"/> <text style="cursor: move;" transform="matrix(0.653316 0 0 0.684165 17.3342 50.9147)" stroke="#2d2d2d" text-anchor="start"  font-size="30" id="svg_33" y="475.53576" x="21.74217" stroke-width="0" fill="#5A5A5A">DEBT LEFT</text> <text style="cursor: move;" text-anchor="start"  font-size="30" id="svg_34" y="416.59967" x="32.03602" stroke-width="0" stroke="#2d2d2d" fill="#848484">',
//                             lenderName,
//                             '</text> <text text-anchor="start"  font-weight="900" font-size="30" id="svg_35" y="415.61451" x="300.42918" stroke-width="0" stroke="#2d2d2d" fill="#AFAFAF">',
//                             (lenderAmount),
//                             "</text>  </svg>"
//                         )
//                     )
//                 )
//             );
//     }

//     function getPrice(
//         address _token,
//         uint amount
//     ) private view returns (string memory) {
//         ERC20 token = ERC20(_token);
//         uint units;
//         string memory amountToReturn;
//         if (_token == address(0x0)) {
//             units = 18;
//         } else {
//             units = token.decimals();
//         }
//         uint decimals = 10 ** units;
//         uint wholeAmount = amount / decimals;
//         uint fractionalAmount = amount % decimals;
//         if (amount < (1 * 10 ** (units - 1))) {
//             if (amount < (1 * 10 ** (units - 2))) {
//                 if (amount == 0) {
//                     amountToReturn = "0";
//                 } else {
//                     amountToReturn = "&lt; 0.01";
//                 }
//             } else {
//                 amountToReturn = string(
//                     abi.encodePacked(
//                         toString(wholeAmount),
//                         ".0",
//                         toString(fractionalAmount / 10 ** (units - 2))
//                     )
//                 );
//             }
//         } else {
//             amountToReturn = string(
//                 abi.encodePacked(
//                     toString(wholeAmount),
//                     ".",
//                     toString(fractionalAmount / 10 ** (units - 2))
//                 )
//             );
//         }

//         return amountToReturn;
//     }

//     function _beforeTokenTransfer(
//         address from,
//         address to,
//         uint256 tokenId
//     ) internal override() {
//         ILoanNex _debita = ILoanNex(LoanNex);
//         uint _id = _debita.loansByNFt(tokenId);
//         ILoanNex.LoanInfo memory loan = _debita.getLOANS_DATA(_id);
//         require(!loan.executed, "Already executed");
//         require(loan.cooldown <= block.timestamp, "Cooldown is not finished");

//     }

//     function getEncoded(uint tokenId) private view returns (string memory) {
//         ILoanNex _debita = ILoanNex(LoanNex);
//         uint _id = _debita.loansByNFt(tokenId);

//         ILoanNex.LoanInfo memory loan = _debita.getLOANS_DATA(_id);
//         ERC20 collateral_1 = ERC20(loan.collaterals[0]);
//         ERC20 collateral_2 = ERC20(
//             loan.collateralAmount.length > 1
//                 ? loan.collaterals[1]
//                 : address(0x0)
//         );
//         ERC20 lender = ERC20(loan.LenderToken);

//         string memory collateral_Name_1 = loan.collaterals[0] == address(0x0)
//             ? "FTM"
//             : collateral_1.symbol();
//         string memory collateral_Name_2 = loan.collateralAmount.length > 1
//             ? loan.collaterals[1] == address(0x0)
//                 ? "FTM"
//                 : collateral_2.symbol()
//             : "";
//         string memory lender_Name = loan.LenderToken == address(0x0)
//             ? "FTM"
//             : lender.symbol();

//         string memory status = (loan.executed == true ||
//             loan.paymentsPaid == loan.paymentCount)
//             ? "Ended"
//             : (loan.deadlineNext < block.timestamp ? "Default" : "Live");
//         string memory _typeBorrow = tokenId % 2 == 1 ? "Lender" : "Borrower";
//         string[3] memory allAmounts = [
//             getPrice(loan.collaterals[0], loan.collateralAmount[0]),
//             loan.collateralAmount.length > 1
//                 ? getPrice(loan.collaterals[1], loan.collateralAmount[1])
//                 : "",
//             getPrice(
//                 loan.LenderToken,
//                 loan.paymentAmount * (loan.paymentCount - loan.paymentsPaid)
//             )
//         ];
//         return
//             buildImage(
//                 _id,
//                 [collateral_Name_1, collateral_Name_2],
//                 (loan.executed ? ["0", "/0"] : [allAmounts[0], allAmounts[1]]),
//                 lender_Name,
//                 allAmounts[2],
//                 status,
//                 _typeBorrow
//             );
//     }

//     function tokenURI(
//         uint tokenId
//     ) public view override returns (string memory) {
//         require(tokenId <= id, "Token Id does not exist");
//         ILoanNex _debita = ILoanNex(LoanNex);
//         uint _id = _debita.loansByNFt(tokenId);

//         string memory data = string(
//             abi.encodePacked(
//                 "data:application/json;base64,",
//                 Base64.encode(
//                     bytes(
//                         abi.encodePacked(
//                             '{"name": "Debita NFT #',
//                             toString(tokenId),
//                             '", "description":"',
//                             "Own the debt, own the position. Debita Finance NFTs represent the ownership of a loan position on-chain.",
//                             '", "external_uri":"',
//                             "https://debita.fi/Loan/",
//                             toString(_id),
//                             '", "image": "',
//                             "data:image/svg+xml;base64,",
//                             getEncoded(tokenId),
//                             '"}'
//                         )
//                     )
//                 )
//             )
//         );
//         return data;
//     }
}