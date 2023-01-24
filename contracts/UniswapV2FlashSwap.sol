//SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "./interface/uniswap/IUniswapV2.sol";
import "./interface/IERC20.sol";
import "hardhat/console.sol";

contract UniswapV2FlashSwap is IUniswapV2Callee {
    // Uniswap V2 router
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // Uniswap V2 factory
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address account = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    event Log(
        uint amount,
        uint _amount0,
        uint _amount1,
        uint fee,
        uint amountToRepay
    );

    function flashSwap(address _tokenBorrow, uint _amount) external {
        console.log("contract before", IERC20(usdc).balanceOf(address(this)));
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenBorrow, WETH);
        require(pair != address(0), "no pair !");
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == token1 ? _amount : 0;
        bytes memory data = abi.encode(_tokenBorrow, _amount);
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    // called by pair contract
    function uniswapV2Call(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);

        require(msg.sender == pair, "no pair !");
        require(_sender == address(this), "!sender");

        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));
        // contract > account => contract
        {
            console.log("contract tl", IERC20(usdc).balanceOf(address(this)));
            console.log("account tl", IERC20(usdc).balanceOf(account));

            uint balance = IERC20(usdc).balanceOf(address(this));
            IERC20(usdc).transfer(account, balance);
            console.log("contract tl", IERC20(usdc).balanceOf(address(this)));
            console.log("account tl", IERC20(usdc).balanceOf(account));

            IERC20(usdc).transferFrom(account, address(this), balance);
            console.log("contract tl", IERC20(usdc).balanceOf(address(this)));
            console.log("account tl", IERC20(usdc).balanceOf(account));
        }
        // about 0.3%
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;
        emit Log(amount, _amount0, _amount1, fee, amountToRepay);

        IERC20(tokenBorrow).transfer(pair, amountToRepay);
        console.log("contract after", IERC20(usdc).balanceOf(address(this)));
    }

    function balanceOf(
        address token,
        address _account
    ) public view returns (uint) {
        return IERC20(token).balanceOf(_account);
    }
}
