// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

import "../interface/IStaking.sol";
import "../interface/IStakingReward.sol";

contract MockStaking is IStaking {
    mapping(address => address) private _referral;
    mapping(address => bool) private _bound;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public teamTotalInvestValue;
    mapping(address => uint256) public teamVirtuallyInvestValue;

    IStakingReward public reward;

    function setReward(address rewardAddress) external {
        reward = IStakingReward(rewardAddress);
    }

    function setReferral(address user, address parent) external {
        _referral[user] = parent;
        _bound[user] = true;
    }

    function setBound(address user, bool bound) external {
        _bound[user] = bound;
    }

    function setBalance(address user, uint256 amount) external {
        balances[user] = amount;
    }

    function setTeamTotals(address user, uint256 total, uint256 virtualValue) external {
        teamTotalInvestValue[user] = total;
        teamVirtuallyInvestValue[user] = virtualValue;
    }

    function notifyStake(address user, uint256 amount) external {
        reward.updateDirectReferralData(user, amount);
    }

    function distribute(address user, uint256 profitReward) external returns (uint256) {
        return reward.newDistributionLogic(user, profitReward);
    }

    function getReferral(address user) external view returns (address) {
        return _referral[user];
    }

    function isBindReferral(address user) external view returns (bool) {
        return _bound[user];
    }
}