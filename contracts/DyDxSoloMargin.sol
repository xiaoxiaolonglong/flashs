// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
pragma experimental ABIEncoderV2;

import "./interface/dydx/DydxFlashloanBase.sol";
import "./interface/dydx/ICallee.sol";
import "hardhat/console.sol";

contract DyDxSoloMargin is ICallee, DydxFlashloanBase {
    address private constant SOLO = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct MyCustomData {
        address token;
        uint repayAmount;
    }

    function initiateFlashLoan(address _token, uint _amount) external {
        ISoloMargin solo = ISoloMargin(SOLO);

        //  寻找能借贷的token
        uint marketId = _getMarketIdFromTokenAddress(SOLO, _token);

        // Calculate repay amount (_amount + (2 wei))
        // 计算需要还多少钱 + 2wei
        uint repayAmount = _getRepaymentAmountInternal(_amount);
        IERC20(_token).approve(SOLO, repayAmount);

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        // 要借多少钱
        operations[0] = _getWithdrawAction(marketId, _amount);

        //  传自己的参数进去callFunction使用
        operations[1] = _getCallAction(
            abi.encode(MyCustomData({token: _token, repayAmount: repayAmount}))
        );

        // 计算还款
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        // 执行以上代码操作
        solo.operate(accountInfos, operations);
    }

    function callFunction(
        address sender, //  address(this)
        Account.Info memory account,
        bytes memory data
    ) public override {
        // solo address
        require(msg.sender == SOLO, "!solo");
        // address(this)
        require(sender == address(this), "!this contract");

        MyCustomData memory mcd = abi.decode(data, (MyCustomData));
        uint repayAmount = mcd.repayAmount;

        uint bal = IERC20(mcd.token).balanceOf(address(this));
        require(bal >= repayAmount, "bal < repay");

        // contract -> account -> contract
        {
            console.log("contract", IERC20(dai).balanceOf(address(this)));
            console.log("account", IERC20(dai).balanceOf(owner));
            
            uint balance = IERC20(dai).balanceOf(address(this));
            IERC20(dai).transfer(owner, balance);
            console.log("contract", IERC20(dai).balanceOf(address(this)));
            console.log("account", IERC20(dai).balanceOf(owner));

            IERC20(dai).transferFrom(owner, address(this), balance);
            console.log("contract", IERC20(dai).balanceOf(address(this)));
            console.log("account", IERC20(dai).balanceOf(owner));
        }
    }
}
