// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

/**
 * @title IStaking Interface
 * @dev Staking 合约接口，用于 StakingReward 合约调用 Staking 合约的函数
 */
interface IStaking {
    /**
     * @dev 获取用户的推荐人地址
     * @param _address 用户地址
     * @return 推荐人地址
     */
    function getReferral(address _address) external view returns(address);
    
    /**
     * @dev 检查用户是否已绑定推荐人
     * @param _address 用户地址
     * @return 是否已绑定
     */
    function isBindReferral(address _address) external view returns(bool);
    
    /**
     * @dev 获取用户余额（mapping 的自动 getter）
     * @param 用户地址
     * @return 余额
     */
    function balances(address) external view returns(uint256);
    
    /**
     * @dev 获取团队总投资价值（mapping 的自动 getter）
     * @param 用户地址
     * @return 团队总投资价值
     */
    function teamTotalInvestValue(address) external view returns(uint256);
    
    /**
     * @dev 获取团队虚拟投资价值（mapping 的自动 getter）
     * @param 用户地址
     * @return 团队虚拟投资价值
     */
    function teamVirtuallyInvestValue(address) external view returns(uint256);
}

