import { parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { bsc8Address, usdcAddress } from "../config/address";



async function main() {
	const UniswapV2FlashSwap = await ethers.getContractFactory("UniswapV2FlashSwap");
	const uniswapV2FlashSwap = await UniswapV2FlashSwap.deploy();
	const uni = await uniswapV2FlashSwap.deployed();
    
	const [ signer ] = await ethers.getSigners();

	const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);
	
	await bsc8.sendTransaction({
		to: signer.address,
		value: parseUnits("100")
	});
	const bsc8Erc20 = new ethers.Contract(
		usdcAddress,
		["function transfer(address to, uint value) external returns (bool)",],
		bsc8
	)

	await bsc8Erc20.transfer(uni.address, parseUnits("3.1", 6))

	const signerErc20 = new ethers.Contract(
		usdcAddress,
		["function approve(address spender, uint value) external returns (bool)"],
		signer
	)
	await signerErc20.approve(uni.address, ethers.constants.MaxUint256);
	
	await uni.flashSwap(usdcAddress, parseUnits("1000", 6));
}



main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
