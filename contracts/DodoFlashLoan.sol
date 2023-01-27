// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interface/IERC20.sol";
import "./interface/dodo/IDPPAdvanced.sol";
import "hardhat/console.sol";

contract DoDoFlashLoan {
    IERC20 WBNB = IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address public constant dodo = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4; //  dodo bsc BNB/BUSD资金池

    struct DPPAdvancedCallBackData {
        uint256 baseAmount;
        uint256 quoteAmount;
    }

    function flashLoan() external {
        uint256 borrownWBNB = 10 * 1e18;
        DPPAdvancedCallBackData memory callData;
        callData.baseAmount = borrownWBNB;
        callData.quoteAmount = 0;
        bytes memory data = abi.encode(callData);
        IDPPAdvanced(dodo).flashLoan(borrownWBNB, 0, address(this), data);
    }

    function DPPFlashLoanCall(
        address sender, // address(this)
        uint256 baseAmount, //  借贷资金
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        // (uint256 bash, uint256 quote) = abi.decode(data, (uint, uint));
        console.log(WBNB.balanceOf(sender) / 1e18);
        WBNB.transfer(dodo, baseAmount);
        console.log(WBNB.balanceOf(sender) / 1e18);
    }
}
