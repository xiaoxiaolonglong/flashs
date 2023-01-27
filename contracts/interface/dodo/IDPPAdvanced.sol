// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
interface IDPPAdvanced {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;
}