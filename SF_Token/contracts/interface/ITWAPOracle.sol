// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ITWAPOracle
 * @notice TWAPOracle 合约接口，供其他合约调用
 */
interface ITWAPOracle {
    /**
     * @notice 获取每日收盘价
     * @return price token0的价格（以token1计价，18位精度）
     */
    function getDailyClosePrice() external view returns (uint256 price);
    
    /**
     * @notice 获取反向每日收盘价（token1的价格，以token0计价）
     * @return price token1的价格（以token0计价，18位精度）
     */
    function getReverseDailyClosePrice() external view returns (uint256 price);
    
    /**
     * @notice 获取代币的每日收盘价（以USDT计价）- 自动识别方向（推荐使用）
     * @return price 代币的价格（以USDT计价，18位精度）
     */
    function getTokenDailyClosePriceInUSDT() external view returns (uint256 price);
    
    /**
     * @notice 获取当前现货价格
     * @return price 当前价格（以token1计价token0，18位精度）
     */
    function getCurrentPrice() external view returns (uint256 price);
    
    /**
     * @notice 获取反向当前价格（token1的价格，以token0计价）
     * @return price token1的当前价格（以token0计价，18位精度）
     */
    function getReverseCurrentPrice() external view returns (uint256 price);
    
    /**
     * @notice 获取代币的当前价格（以USDT计价）- 自动识别方向（推荐使用）
     * @return price 代币的当前价格（以USDT计价，18位精度）
     */
    function getTokenCurrentPriceInUSDT() external view returns (uint256 price);
    
    /**
     * @notice 计算价格涨跌幅（基于代币:USDT价格）- 自动识别方向（推荐使用）
     * @return priceChangeBps 涨跌幅（基点），正数表示上涨，负数表示下跌
     */
    function getPriceChangeBps() external view returns (int256 priceChangeBps);
    
    /**
     * @notice 计算价格涨跌幅绝对值（用于税收计算）- 自动识别方向（推荐使用）
     * @return priceChangeBps 涨跌幅绝对值（基点），始终为正数
     */
    function getPriceChangeBpsAbs() external view returns (uint256 priceChangeBps);
    
    /**
     * @notice 获取追踪的代币信息
     * @return tokenAddress 当前追踪的代币地址
     * @return quoteTokenAddress 计价代币地址
     * @return isToken0Tracked 追踪的代币是否为token0
     */
    function getTrackedTokenInfo() external view returns (
        address tokenAddress,
        address quoteTokenAddress,
        bool isToken0Tracked
    );
    
    /**
     * @notice 检查指定地址是否为当前追踪的代币
     * @param tokenAddress 要检查的代币地址
     * @return isTracked 是否为追踪的代币
     * @return isToken0 是否为token0
     * @return isToken1 是否为token1
     */
    function isTrackedToken(address tokenAddress) external view returns (
        bool isTracked,
        bool isToken0,
        bool isToken1
    );
    
    /**
     * @notice 设置USDT地址（用于自动识别）
     * @param _usdtAddress USDT代币地址
     */
    function setUSDTAddress(address _usdtAddress) external;
    
    /**
     * @notice 验证池子配置（用于确认USDT和代币的识别是否正确）
     * @return pairAddress LP地址
     * @return token0Address token0地址
     * @return token1Address token1地址
     * @return usdtAddress_ USDT地址
     * @return isToken0USDT_ token0是否为USDT
     * @return trackedToken_ 被追踪的代币地址
     * @return priceDirection 价格方向说明
     */
    function verifyPairConfiguration() external view returns (
        address pairAddress,
        address token0Address,
        address token1Address,
        address usdtAddress_,
        bool isToken0USDT_,
        address trackedToken_,
        string memory priceDirection
    );
}
