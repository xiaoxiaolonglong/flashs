# 智能合约闪电系列
区块链智能合约`uniswapV2闪电兑`以及`aaveV2和dydx闪电贷`系列合集。
## 项目操作
### 下载依赖
```
yarn || npm i
```
### 创建.env文件
```
ALCHEMY_KEY = xxxxxx
```
### fork主网
```
npx hardhat node
```
### 调用测试
```
npx hardhat scripts/dydxSoloMargin.ts
npx hardhat scripts/AaveV2FlashLoan.ts
npx hardhat scripts/uniswapV2Flash.ts
```
## uniswapV2FlashSwap
+ 手续费 0.03(千分之三)
+ 币种，只要是uniswapV2的交易对都能进行借贷操作
## aaveV2FalshLoan
+ 手续费 0.009(万分之九)
+ 币种主要多为主流币
## DyDxSoloMargin
+ 手续费 几乎为0
+ 币种单一

笔记文档：[区块链笔记](https://www.yuque.com/qdwds)

哔哩哔哩：[视频合集](https://space.bilibili.com/449244768?spm_id_from=333.1007.0.0)