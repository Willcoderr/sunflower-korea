// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

/**
 * @title ISFExchange Interface
 * @notice SF 兑换合约接口（中间合约）
 * @dev 用于质押合约与 SF 兑换合约的交互
 */
interface ISFExchange {
    // ============ Events ============
    
    event ExchangeUSDTForSF(address indexed user, uint256 usdtAmount, uint256 sfAmount);
    event ExchangeSFForUSDT(address indexed user, uint256 sfAmount, uint256 usdtAmount);
    event WhitelistDeposit(address indexed from, uint256 sfAmount, uint256 usdtAmount);
    event StakingContractUpdated(address indexed oldContract, address indexed newContract);
    event ReserveThresholdUpdated(uint256 minSFReserve, uint256 minUSDTReserve);
    
    // ============ Core Functions ============
    
    /**
     * @dev 质押时：USDT → SF（无税）
     * @param usdtAmount USDT 数量
     * @return sfAmount 返回的 SF 数量
     * @notice 只能由授权的质押合约调用
     */
    function exchangeUSDTForSF(uint256 usdtAmount) external returns (uint256 sfAmount);
    
    /**
     * @dev 解押时：SF → USDT
     * @param sfAmount SF 数量
     * @return usdtAmount 返回的 USDT 数量
     * @notice 只能由授权的质押合约调用
     */
    function exchangeSFForUSDT(uint256 sfAmount) external returns (uint256 usdtAmount);
    
    // ============ Admin Functions ============
    
    /**
     * @dev 白名单充值（链下购买后转入）
     * @param sfAmount SF 数量
     * @param usdtAmount USDT 数量
     * @notice 只能由 owner 调用
     */
    function depositFromWhitelist(uint256 sfAmount, uint256 usdtAmount) external;
    
    /**
     * @dev 设置质押合约地址
     * @param _stakingContract 新的质押合约地址
     */
    function setStakingContract(address _stakingContract) external;
    
    /**
     * @dev 设置最小储备金阈值
     * @param _minSFReserve 最小 SF 储备
     * @param _minUSDTReserve 最小 USDT 储备
     */
    function setReserveThresholds(uint256 _minSFReserve, uint256 _minUSDTReserve) external;
    
    /**
     * @dev 紧急提取（仅 owner）
     * @param token 代币地址
     * @param amount 提取数量
     * @param to 接收地址
     */
    function emergencyWithdraw(address token, uint256 amount, address to) external;
    
    // ============ View Functions ============
    
    /**
     * @dev 计算兑换价格（基于 SF/USDT 池）
     * @param usdtAmount USDT 数量
     * @return SF 数量
     */
    function calculateSFAmount(uint256 usdtAmount) external view returns (uint256);
    
    /**
     * @dev 计算兑换价格（基于 SF/USDT 池）
     * @param sfAmount SF 数量
     * @return USDT 数量
     */
    function calculateUSDTAmount(uint256 sfAmount) external view returns (uint256);
    
    /**
     * @dev 查询储备金状态
     * @return sfBalance SF 余额
     * @return usdtBalance USDT 余额
     * @return sfSufficient SF 储备是否充足
     * @return usdtSufficient USDT 储备是否充足
     */
    function getReserveStatus() external view returns (
        uint256 sfBalance,
        uint256 usdtBalance,
        bool sfSufficient,
        bool usdtSufficient
    );
    
    /**
     * @dev 获取配置参数
     * @return minSFReserve 最小 SF 储备
     * @return minUSDTReserve 最小 USDT 储备
     * @return stakingContract 授权的质押合约地址
     */
    function getConfig() external view returns (
        uint256 minSFReserve,
        uint256 minUSDTReserve,
        address stakingContract
    );
}

