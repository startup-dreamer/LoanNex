//-------------------------------------------------- **AurumV2 Description Report** --------------------------------------------------//

//-------------------------------------------------- Files Description Table --------------------------------------------------//

| File Name            | SHA-1 Hash    |
|----------------------|--------------|
| AurumAdmin.sol       |53088fada5d715a0ef198571dab5835d765134f5|
| NFTEscrow.sol        |4261970d979f470abd13ddbae35a3a1b8422aecc|
| NFTPrice.sol         |183439385d3f40c8be12b762a7781c215a6afcd6|
| AurumV2core.sol      |963c891fb05bb3d526192173ad4f9adc14cadf09|

//-------------------------------------------------- Contracts Description Table --------------------------------------------------//

| Contract           | Type           | Bases               | Function Name    | Visibility   | Mutability | Modifiers    |
|:------------------:|:--------------:|:-------------------:|:----------------:|:------------:|:----------:|:------------:|
| **NFTEscrow**      | Implementation | ERC721Holder        | depositERC721Collateral | Internal    | 🛑          |              |
| └                  |                 |                     | withdrawERC721Collateral | Internal    | 🛑          |              |
| **AurumAdmin**     | Implementation | Ownable             | getUtillization  | External     | ❗️          |              |
| └                  |                 |                     | setBorrowInterestRate  | Public     | 🛑          | onlyOwner    |
| └                  |                 |                     | setLoanToValue   | Public       | 🛑          | onlyOwner    |
| └                  |                 |                     | calculateInterest | Internal   |             |              |
| **NFTPrice**       | Implementation |                     | getNFTPrice      | Public       | ❗️          |              |
| └                  |                 |                     | get_ETHtoUSD_Price  | Public    | ❗️          |              |
| └                  |                 |                     | _getNFTPrice     | Internal   |             |              |
| **AurumV2core**    | Implementation | AurumAdmin, NFTEscrow, NFTPrice | Constructor | Public  | ❗️          | 💵          |NO❗️  |
| └                  |                 |                     | Fallback       | External     | ❗️          | 💵          |NO❗️  |
| └                  |                 |                     | Receive Ether  | External     | ❗️          | 💵          |NO❗️  |
| └                  |                 |                     | depositToPool    | External     | ❗️          | 💵          |NO❗️  |
| └                  |                 |                     | withdrawFromPool | External    | ❗️          | 🛑          |NO❗️  |
| └                  |                 |                     | borrow           | External     | ❗️          | 💵          |NO❗️  |
| └                  |                 |                     | repay            | External     | ❗️          | 💵          |NO❗️  |
| └                  |                 |                     | getNftCollateralValue | Public  | ❗️          |             |NO❗️  |

![](./contracts/V2/schema.svg)
<br><br>

//-------------------------------------------------- **AurumV1 Description Report** --------------------------------------------------//

//-------------------------------------------------- Files Description Table --------------------------------------------------//

|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| AurumV1core.sol | c480ebc177b63d529c31f3f217e179be4b4c60c7 |
| NFTPrice.sol | 3acf33be1ca018e11bef3e335d291dc4d98dfafb |

//-------------------------------------------------- Contracts Description Table --------------------------------------------------//

|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
|            |                     |                  |                  |                 |
| **AurumV1core** | Implementation | NFTPrice         |                  |                 |
| └ | Constructor | Public ❗️ |  💵 |NO❗️ |
| └ | Fallback | External ❗️ |  💵 |NO❗️ |
| └ | Receive Ether | External ❗️ |  💵 |NO❗️ |
| └ | depositToPool | External ❗️ |  💵 |NO❗️ |
| └ | withdrawFromPool | External ❗️ | 🛑  |NO❗️ |
| └ | borrow | External ❗️ |  💵 |NO❗️ |
| └ | repay | External ❗️ |  💵 |NO❗️ |
| └ | set_Borrow_InterestRate | External ❗️ | 🛑  |NO❗️ |
| └ | setLoanToCollateral | External ❗️ | 🛑  |NO❗️ |
| └ | getUtilization | External ❗️ |   |NO❗️ |
| └ | withdraw_liquidateNFT | External ❗️ |  💵 |NO❗️ |
| └ | getNftCollateralValue | Public ❗️ |   |NO❗️ |
| └ | depositERC721Collateral | Internal 🔒 | 🛑  | |
| └ | withdrawERC721Collateral | Internal 🔒 | 🛑  | |
|            |                     |                  |                  |                 |
| **NFTPrice** | Implementation |                  |                  |                 |
| └ | getNFTPrice | Public ❗️ |   |NO❗️ |
| └ | get_ETHtoUSD_Price | Public ❗️ |   |NO❗️ |
| └ | _getNFTPrice | Internal 🔒 |   | |

//-------------------------------------------------- Legend --------------------------------------------------//

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |

![](./contracts/V1/schema.svg)
