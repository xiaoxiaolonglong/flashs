// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;
import {FlashLoanReceiverBase} from "./interface/aave/FlashLoanReceiverBase.sol";
import {SafeMath} from "./interface/aave/SafeMath.sol";
import {IFlashLoanReceiver, ILendingPoolAddressesProvider} from "./interface/aave/IFlashLoanReceiver.sol";
import {IERC20} from "./interface/IERC20.sol";

import "hardhat/console.sol";

// contract AaveV2FlashLoan{
contract AaveV2FlashLoan is FlashLoanReceiverBase {
    using SafeMath for uint256;

    event Log(string message, uint val);

    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public aave = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

    address public dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public link = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address account = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor(
        ILendingPoolAddressesProvider _addressProvider
    ) public FlashLoanReceiverBase(_addressProvider) {}

    function flashLoan(address asset, uint amount) external {
        address receiver = address(this);

        // 可以借多种资产
        address[] memory assets = new address[](1);
        assets[0] = asset;

        // 借贷额度
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        // 0=flashLoan, 1=tasble(固定年利率)，2=variable(动态年利率)
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        // 代表谁来借
        address onBehalfOf = address(this);
        bytes memory params = "CrytoLeeK test falshLoan"; //可以留下信息
        uint16 referralCode = 0;

        // 调用这个方法的时候 就会去执行 executeOperation
        LENDING_POOL.flashLoan(
            receiver,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    function executeOperation(
        address[] calldata assets, //  借款合约地址
        uint[] calldata amounts, //  借款额度
        uint[] calldata premiums, //  利息0.09%
        address initiator, //  借款地址(address(this))
        bytes calldata params //  留言信息
    ) external override returns (bool) {
        // contract -> account -> contract
        {
            console.log("contract", IERC20(assets[0]).balanceOf(address(this)));
            console.log("account", IERC20(assets[0]).balanceOf(account));

            uint balance = IERC20(assets[0]).balanceOf(address(this));
            IERC20(assets[0]).transfer(account, balance);
            console.log("contract", IERC20(assets[0]).balanceOf(address(this)));
            console.log("account", IERC20(assets[0]).balanceOf(account));

            IERC20(assets[0]).transferFrom(account, address(this), balance);
            console.log("contract", IERC20(assets[0]).balanceOf(address(this)));
            console.log("account", IERC20(assets[0]).balanceOf(account));
        }

        // 批量还款
        for (uint i = 0; i < assets.length; i++) {
            // emit Log("borrowed", amounts[i]);
            // emit Log("fee", premiums[i]);
            console.log(amounts[i], premiums[i]);
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        // repay Aave
        return true;
    }
}
