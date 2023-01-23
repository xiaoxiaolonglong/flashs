import { HardhatUserConfig } from "hardhat/config";
import { config as dotenv } from "dotenv";
dotenv();


import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
	networks: {
		hardhat: {
			forking: {
				url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
			}
		}
	},
	solidity: {
		compilers: [
			{ version: "0.8.0" },
			{ version: "0.5.16" },
			{ version: "0.6.12" },
		]
	},
};

export default config;
