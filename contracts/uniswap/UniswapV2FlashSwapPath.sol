//SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "../interface/uniswap/IUniswapV2.sol";
import "../interface/IERC20.sol";
import "hardhat/console.sol";

contract UniswapV2FlashSwapPath is IUniswapV2Callee {
    // Uniswap V2 factory
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    event Log(
        uint amount,
        uint _amount0,
        uint _amount1,
        uint fee,
        uint amountToRepay
    );

    function flashSwap(address[] memory _tokenPath, uint _amount) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenPath[0] ,_tokenPath[1]);
        require(pair != address(0), "no pair !");
        {
            address token0 = IUniswapV2Pair(pair).token0();
            address token1 = IUniswapV2Pair(pair).token1();
            uint amount0Out = _tokenPath[0] == token0 ? _amount : 0;
            uint amount1Out = _tokenPath[0] == token1 ? _amount : 0;
            bytes memory data = abi.encode(_tokenPath, _amount);
            IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
        }
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

        (address[] memory tokenPath, uint amount) = abi.decode(_data, (address[], uint));
        address tokenOne = tokenPath[0];
      
        for (uint i = 0; i < tokenPath.length; i++) {
            if(tokenPath[i] != tokenOne){
                console.log(tokenPath[i]);
            }
        }
       
        // about 0.3%
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;
        emit Log(amount, _amount0, _amount1, fee, amountToRepay);

        IERC20(tokenOne).transfer(pair, amountToRepay);
    }

    function balanceOf(
        address token,
        address _account
    ) public view returns (uint) {
        return IERC20(token).balanceOf(_account);
    }

  
}
