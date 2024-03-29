import { parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { bsc8Address, usdcAddress } from "../config/address";

const ERC20ABI = require("@uniswap/v2-core/build/ERC20.json").abi;

async function main() {
	const UniswapV2FlashSwap = await ethers.getContractFactory("UniswapV2FlashSwap");
	const uniswapV2FlashSwap = await UniswapV2FlashSwap.deploy();
	const uni = await uniswapV2FlashSwap.deployed();
    
	// 提供的一个钱包
	const [ signer ] = await ethers.getSigners();

	// 冒充任何地址。即使您无权访问其私钥，这也使您可以从该帐户发送交易。
	const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);

	let balance;
	/* balance = await bsc8.getBalance();
	console.log('账户转帐前余额：', ethers.utils.formatUnits(balance.toString()));
	await bsc8.sendTransaction({
		to: signer.address,
		value: parseUnits("100")
	});
	balance = await bsc8.getBalance();
	console.log('账户转帐后余额：', ethers.utils.formatUnits(balance.toString())); */

	const bsc8Erc20 = new ethers.Contract(
		usdcAddress,
		ERC20ABI,
		bsc8
	)
	balance = await bsc8Erc20.balanceOf(bsc8.address);
	console.log('合约转帐前余额：', ethers.utils.formatUnits(balance.toString()));
	// 提前把利率转入合约中 0.3%的利率，避免无法还款导致交易回滚损失gas费
	// 账户里面要有余额，否者会报错reverted with reason string 'ERC20: transfer amount exceeds balance
	// todo 正式环境需要修改转账的逻辑，甚至可以不要这个逻辑，通过小狐狸钱包手动转入
	await bsc8Erc20.transfer(uni.address, parseUnits("3.1", 6))

	const signerErc20 = new ethers.Contract(
		usdcAddress,
		["function approve(address spender, uint value) external returns (bool)"],
		signer
	)
	// 因为还钱的时候需要转账，需要用户和合约授权
	await signerErc20.approve(uni.address, ethers.constants.MaxUint256);
	
	await uni.flashSwap(usdcAddress, parseUnits("1000", 6));
}



main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
