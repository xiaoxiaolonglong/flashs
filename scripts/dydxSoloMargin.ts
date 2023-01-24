import { formatUnits, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { bsc8Address, daiAddress, usdcAddress } from "../config/address";

async function main() {
    const DyDxSoloMargin = await ethers.getContractFactory("DyDxSoloMargin");
    const dyDxSoloMargin = await DyDxSoloMargin.deploy({gasLimit:3000000});
    const dydx = await dyDxSoloMargin.deployed();

    const [ signer ] = await ethers.getSigners();

	const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);

    await bsc8.sendTransaction({
		to: signer.address,
		value: parseUnits("100")
	});
	const bsc8Dai = new ethers.Contract(
		daiAddress,
		["function transfer(address to, uint value) external returns (bool)","function balanceOf(address owner) external view returns (uint)"],
		bsc8
	)

    await bsc8Dai.transfer(dydx.address, parseUnits("1"));

    const signerErc20 = new ethers.Contract(
		daiAddress,
		["function approve(address spender, uint value) external returns (bool)","function balanceOf(address owner) external view returns (uint)"],
		signer
	)
	await signerErc20.approve(dydx.address, ethers.constants.MaxUint256);
        
    await dydx.initiateFlashLoan(daiAddress, parseUnits("1000000"));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
