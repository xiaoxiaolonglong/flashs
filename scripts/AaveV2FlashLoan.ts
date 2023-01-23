import { parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { bsc8Address, usdcAddress } from "../config/address";

async function main() {
    const AaveV2FlashLoan = await ethers.getContractFactory("AaveV2FlashLoan");
    const aaveV2FlashLoan = await AaveV2FlashLoan.deploy("0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5",{gasLimit:3000000});
    const flashLoan = await aaveV2FlashLoan.deployed();

    const [ signer ] = await ethers.getSigners();

	const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);

    await bsc8.sendTransaction({
		to: signer.address,
		value: parseUnits("100")
	});
	const bsc8Usdc = new ethers.Contract(
		usdcAddress,
		["function transfer(address to, uint value) external returns (bool)"],
		bsc8
	)

    await bsc8Usdc.transfer(flashLoan.address, parseUnits("9", 6));
   
    const signerErc20 = new ethers.Contract(
		usdcAddress,
		["function approve(address spender, uint value) external returns (bool)","function balanceOf(address owner) external view returns (uint)"],
		signer
	)
	await signerErc20.approve(flashLoan.address, ethers.constants.MaxUint256);
        
    await flashLoan.flashLoan(usdcAddress, parseUnits("10000", 6));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
