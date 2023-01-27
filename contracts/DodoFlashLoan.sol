// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IERC20.sol";
import "./interface/dodo/IDPPAdvanced.sol";
import "hardhat/console.sol";

contract DoDoFlashLoan {
    IERC20 Token = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public constant dodo = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4; //  dodo 资金池

    struct DPPAdvancedCallBackData {
        uint256 baseAmount;
        uint256 quoteAmount;
    }

    function flashLoan() external {
        console.log(block.number);
        uint256 borrownToken = 1726873078546794758063;
        DPPAdvancedCallBackData memory callData;
        callData.baseAmount = borrownToken;
        callData.quoteAmount = 0;
        bytes memory data = abi.encode(callData);
        IDPPAdvanced(dodo).flashLoan(borrownToken, 0, address(this), data);
    }

    function DPPFlashLoanCall(
        address sender, // address(this)
        uint256 baseAmount, //  借贷资金
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        // (uint256 bash, uint256 quote) = abi.decode(data, (uint, uint));
        console.log(Token.balanceOf(sender));
        Token.transfer(dodo, baseAmount);
        console.log(Token.balanceOf(sender));
    }
}
