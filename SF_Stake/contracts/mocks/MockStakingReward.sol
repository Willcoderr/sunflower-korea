// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockStakingReward {
    address public lastUser;
    uint256 public lastProfit;
    uint256 public callCount;

    function updateDirectReferralData(address, uint256) external {}

    function newDistributionLogic(address user, uint256 profitReward) external returns (uint256) {
        lastUser = user;
        lastProfit = profitReward;
        callCount += 1;
        return profitReward;
    }
}
