// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

interface IStakingReward {
    function updateDirectReferralData(address user, uint256 amount) external;
    function newDistributionLogic(address _user, uint256 profitReward) external returns (uint256);
    function getDirectReferralCount(address user) external view returns (uint256);
    function getTeamLevel(address user) external view returns (uint256);
    function getNewDistributionInfo(address user) external view returns (
        uint256 referralProfit,
        uint256 teamProfit,
        uint256 teamLevelValue,
        uint256 directCount,
        bool canClaimReward
    );
    function getDepartmentStats(address user) external view returns (
        uint256 count3,
        uint256 count4,
        uint256 count5,
        uint256 dept1Level,
        uint256 dept2Level,
        uint256 teamKpi
    );
    function emitUnstakePerformanceUpdate(address user,uint256 amount) external;
}

