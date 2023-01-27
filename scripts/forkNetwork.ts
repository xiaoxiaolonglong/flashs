import { formatUnits } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { bsc8Address, usdcAddress } from "../config/address";



async function main() {
	const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);
	const bsc8Erc20 = new ethers.Contract(
		usdcAddress,
        ["function balanceOf(address owner) external view returns (uint)"],
        bsc8
	)

	console.log(formatUnits( await bsc8Erc20.balanceOf(bsc8.address),6))
}



main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
