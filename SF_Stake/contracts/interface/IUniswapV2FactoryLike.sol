// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

/**
 * @title IStaking Interface
 * @dev Staking 合约接口，用于 StakingReward 合约调用 Staking 合约的函数
 */
interface IUniswapV2FactoryLike {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
