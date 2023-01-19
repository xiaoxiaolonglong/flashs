import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ContractReceipt } from "ethers";
import { parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat"
import { bsc8Address, usdcAddress } from "./config";

const { expect } = require("chai");

/***
 * 转账usdc 到falshswpa中
 * 
 */
describe("UniswapV2FlashSwap", () => {

	const deployUniswapV2FlashSwapFixture = async () => {
		const UniswapV2FlashSwap = await ethers.getContractFactory("UniswapV2FlashSwap");
		const uniswapV2FlashSwap = await UniswapV2FlashSwap.deploy();

		const [signer] = await ethers.getSigners();
		const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);
		const erc20 = new ethers.Contract(usdcAddress, ["function transfer(address to, uint value) external returns (bool)","function balanceOf(address owner) external view returns (uint)"], bsc8)
		return {
			uniswapV2FlashSwap,
			signer,
			erc20,
		}
	}

	it("falsh swap", async () => {
		const { uniswapV2FlashSwap, signer, erc20 } = await loadFixture(deployUniswapV2FlashSwapFixture);
		await erc20.transfer(uniswapV2FlashSwap.address, parseUnits("300", 6));
		const result = await uniswapV2FlashSwap.flashSwap( usdcAddress, parseUnits("100", 6));
		const tx = await result.wait();
		for (const log of tx.events) {
			if(log.event == "Log"){
				console.log(log.args)
			}
		}
		
	})


})