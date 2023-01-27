import { formatUnits, parseUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { bsc8Address, daiAddress, usdcAddress } from "../config/address";

async function main() {
    const DoDoFlashLoan = await ethers.getContractFactory("DoDoFlashLoan");
    const doDoFlashLoan = await DoDoFlashLoan.deploy({gasLimit:3000000});
    const dodo = await doDoFlashLoan.deployed();
    const [ signer ] = await ethers.getSigners();

	const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);

    await bsc8.sendTransaction({
		to: signer.address,
		value: parseUnits("1")
	});
	
    await dodo.flashLoan();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
