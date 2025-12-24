// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Owned} from "solmate/src/auth/Owned.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {ITWAPOracle} from "./interface/ITWAPOracle.sol";

/**
 * @title TWAPOracle
 * @notice 时间加权平均价格预言机，支持链下调用更新价格
 * @dev 用于计算TWAP价格、历史价格和滑点
 */
contract TWAPOracle is ITWAPOracle, Owned {
    // ============ 存储结构 ============
    
    struct PriceSnapshot {
        uint112 price;      // 价格（18位精度）
        uint40 timestamp;   // 时间戳
        bool exists;        // 是否存在
    }
    
    struct PairInfo {
        address pairAddress;    // 交易对地址
        address token0Address;  // token0地址
        address token1Address;  // token1地址
        bool isToken0Tracked;   // 追踪的代币是否为token0
    }
    
    // ============ 状态变量 ============
    
    address public immutable trackedToken;      // 被追踪的代币地址（SFK）
    address public immutable quoteToken;         // 计价代币地址（USDT）
    address public usdtAddress;                  // USDT地址（可配置）
    
    PairInfo public pairInfo;                     // 交易对信息
    
    // 价格快照存储（循环缓冲区，最多存储24小时的数据，每小时一个快照）
    uint256 public constant MAX_SNAPSHOTS = 24;
    PriceSnapshot[MAX_SNAPSHOTS] public priceSnapshots;
    uint256 public snapshotCount;                // 当前快照数量
    uint256 public oldestSnapshotIndex;         // 最旧快照的索引
    
    // 每日收盘价
    mapping(uint256 => uint256) public dailyClosePrices; // day => price
    uint256 public lastDailyClosePrice;          // 最后一次每日收盘价
    uint256 public lastDailyCloseDay;            // 最后一次每日收盘的日期
    
    // 更新者权限（链下服务地址）
    mapping(address => bool) public updaters;
    
    // ============ 事件 ============
    
    event PriceUpdated(uint256 price, uint256 timestamp);
    event DailyClosePriceUpdated(uint256 day, uint256 price);
    event UpdaterAdded(address indexed updater);
    event UpdaterRemoved(address indexed updater);
    event USDTAddressSet(address indexed usdtAddress);
    
    // ============ 修饰符 ============
    
    modifier onlyUpdater() {
        require(updaters[msg.sender] || msg.sender == owner, "Not authorized updater");
        _;
    }
    
    // ============ 构造函数 ============
    
    /**
     * @param _trackedToken 被追踪的代币地址（SFK）
     * @param _quoteToken 计价代币地址（USDT）
     * @param _pairAddress Uniswap V2 交易对地址
     * @param _owner 合约所有者
     */
    constructor(
        address _trackedToken,
        address _quoteToken,
        address _pairAddress,
        address _owner
    ) Owned(_owner) {
        require(_trackedToken != address(0), "Invalid tracked token");
        require(_quoteToken != address(0), "Invalid quote token");
        require(_pairAddress != address(0), "Invalid pair address");
        
        trackedToken = _trackedToken;
        quoteToken = _quoteToken;
        usdtAddress = _quoteToken; // 默认USDT地址
        
        // 获取交易对信息
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);
        address token0 = pair.token0();
        address token1 = pair.token1();
        
        bool isToken0Tracked = (token0 == _trackedToken);
        require(
            (token0 == _trackedToken || token1 == _trackedToken),
            "Tracked token not in pair"
        );
        
        pairInfo = PairInfo({
            pairAddress: _pairAddress,
            token0Address: token0,
            token1Address: token1,
            isToken0Tracked: isToken0Tracked
        });
        
        // 注意：不在构造函数中初始化价格快照
        // 因为此时交易对可能还没有流动性，会导致部署失败
        // 部署后需要手动调用 updatePriceSnapshot() 来初始化第一个快照
    }
    
    // ============ 价格更新函数（链下调用） ============
    
    /**
     * @notice 更新价格快照（由链下服务调用）
     * @dev 每小时最多更新一次，避免频繁更新浪费gas
     */
    function updatePriceSnapshot() external onlyUpdater {
        _updatePriceSnapshot();
    }
    
    /**
     * @notice 更新每日收盘价（由链下服务调用）
     * @dev 每天更新一次，通常在UTC 00:00更新
     */
    function updateDailyClosePrice() public onlyUpdater {
        uint256 currentDay = block.timestamp / 1 days;
        
        // 如果今天还没有更新过，或者已经过了新的一天
        if (lastDailyCloseDay < currentDay) {
            // 获取当前价格作为收盘价
            uint256 currentPrice = getTokenCurrentPriceInUSDT();
            dailyClosePrices[currentDay] = currentPrice;
            lastDailyClosePrice = currentPrice;
            lastDailyCloseDay = currentDay;
            
            emit DailyClosePriceUpdated(currentDay, currentPrice);
        }
    }
    
    /**
     * @notice 批量更新价格和收盘价（由链下服务调用）
     * @dev 一次性更新价格快照和每日收盘价，节省gas
     */
    function updatePriceAndClosePrice() external onlyUpdater {
        _updatePriceSnapshot();
        updateDailyClosePrice();
    }
    
    // ============ 内部价格更新函数 ============
    
    /**
     * @dev 内部函数：更新价格快照
     */
    function _updatePriceSnapshot() internal {
        // 检查交易对是否有流动性（储备量不为0）
        IUniswapV2Pair pair = IUniswapV2Pair(pairInfo.pairAddress);
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        
        // 如果储备量为0，说明交易对还没有流动性，无法计算价格
        if (reserve0 == 0 || reserve1 == 0) {
            return;
        }
        
        uint256 currentPrice = getTokenCurrentPriceInUSDT();
        uint40 currentTimestamp = uint40(block.timestamp);
        
        // 检查是否需要更新（至少间隔1小时）
        if (snapshotCount > 0) {
            PriceSnapshot memory lastSnapshot = priceSnapshots[
                (oldestSnapshotIndex + snapshotCount - 1) % MAX_SNAPSHOTS
            ];
            
            // 如果距离上次更新不足1小时，且价格变化小于5%，则不更新
            if (currentTimestamp < lastSnapshot.timestamp + 1 hours) {
                uint256 priceChange = currentPrice > lastSnapshot.price
                    ? ((currentPrice - lastSnapshot.price) * 10000) / lastSnapshot.price
                    : ((lastSnapshot.price - currentPrice) * 10000) / lastSnapshot.price;
                
                // 价格变化小于5%且时间间隔不足1小时，不更新
                if (priceChange < 500) {
                    return;
                }
            }
        }
        
        // 确定存储位置
        uint256 index;
        if (snapshotCount < MAX_SNAPSHOTS) {
            // 还有空间，追加
            index = snapshotCount;
            snapshotCount++;
        } else {
            // 已满，覆盖最旧的
            index = oldestSnapshotIndex;
            oldestSnapshotIndex = (oldestSnapshotIndex + 1) % MAX_SNAPSHOTS;
        }
        
        // 存储新快照
        priceSnapshots[index] = PriceSnapshot({
            price: uint112(currentPrice),
            timestamp: currentTimestamp,
            exists: true
        });
        
        emit PriceUpdated(currentPrice, currentTimestamp);
    }
    
    // ============ 价格查询函数 ============
    
    /**
     * @notice 获取当前现货价格（从交易对直接读取）
     */
    function getCurrentPrice() external view override returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairInfo.pairAddress);
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        
        if (pairInfo.isToken0Tracked) {
            // token0是被追踪的代币，价格 = reserve1 / reserve0
            return (uint256(reserve1) * 1e18) / reserve0;
        } else {
            // token1是被追踪的代币，价格 = reserve0 / reserve1
            return (uint256(reserve0) * 1e18) / reserve1;
        }
    }
    
    /**
     * @notice 获取反向当前价格
     */
    function getReverseCurrentPrice() external view override returns (uint256) {
        uint256 price = this.getCurrentPrice();
        return (1e18 * 1e18) / price; // 反向价格
    }
    
    /**
     * @notice 获取代币的当前价格（以USDT计价）- 自动识别方向
     */
    function getTokenCurrentPriceInUSDT() public view override returns (uint256) {
        // 如果计价代币就是USDT，直接返回当前价格
        if (quoteToken == usdtAddress) {
            return this.getCurrentPrice();
        }
        
        // 否则需要计算（这里简化处理，假设quoteToken就是USDT）
        return this.getCurrentPrice();
    }
    
    /**
     * @notice 获取每日收盘价
     */
    function getDailyClosePrice() external view override returns (uint256) {
        if (lastDailyClosePrice == 0) {
            // 如果没有收盘价，返回当前价格
            return getTokenCurrentPriceInUSDT();
        }
        return lastDailyClosePrice;
    }
    
    /**
     * @notice 获取反向每日收盘价
     */
    function getReverseDailyClosePrice() external view override returns (uint256) {
        uint256 price = this.getDailyClosePrice();
        return (1e18 * 1e18) / price;
    }
    
    /**
     * @notice 获取代币的每日收盘价（以USDT计价）
     */
    function getTokenDailyClosePriceInUSDT() external view override returns (uint256) {
        return this.getDailyClosePrice();
    }
    
    /**
     * @notice 获取TWAP价格（时间加权平均价格）
     * @param interval 时间间隔（秒），例如3600表示过去1小时
     * @return price TWAP价格
     */
    function getTWAPPrice(uint256 interval) external view returns (uint256 price) {
        require(interval > 0, "Interval must be greater than 0");
        require(snapshotCount > 0, "No price snapshots available");
        
        uint256 targetTimestamp = block.timestamp >= interval 
            ? block.timestamp - interval 
            : 0;
        
        uint256 totalWeightedPrice = 0;
        uint256 totalWeight = 0;
        uint256 lastTimestamp = block.timestamp;
        
        // 从最新到最旧遍历快照
        for (uint256 i = 0; i < snapshotCount; i++) {
            uint256 index = (oldestSnapshotIndex + snapshotCount - 1 - i) % MAX_SNAPSHOTS;
            PriceSnapshot memory snapshot = priceSnapshots[index];
            
            if (!snapshot.exists || snapshot.timestamp < targetTimestamp) {
                break;
            }
            
            // 计算时间权重（距离现在越近，权重越大）
            uint256 weight = lastTimestamp - snapshot.timestamp;
            if (weight == 0) weight = 1; // 避免除零
            
            totalWeightedPrice += snapshot.price * weight;
            totalWeight += weight;
            
            lastTimestamp = snapshot.timestamp;
        }
        
        if (totalWeight == 0) {
            // 如果没有有效快照，返回当前价格
            return getTokenCurrentPriceInUSDT();
        }
        
        return totalWeightedPrice / totalWeight;
    }
    
    /**
     * @notice 获取最近N小时的平均价格
     * @param hoursBack 小时数
     */
    function getAveragePrice(uint256 hoursBack) external view returns (uint256) {
        return this.getTWAPPrice(hoursBack * 1 hours);
    }
    
    /**
     * @notice 获取价格快照
     * @param timestamp 时间戳
     * @return price 价格
     * @return exists 是否存在
     */
    function getPriceSnapshot(uint256 timestamp) external view returns (uint256 price, bool exists) {
        // 查找最接近的时间戳
        uint256 closestIndex = type(uint256).max;
        uint256 closestDiff = type(uint256).max;
        
        for (uint256 i = 0; i < snapshotCount; i++) {
            uint256 index = (oldestSnapshotIndex + i) % MAX_SNAPSHOTS;
            PriceSnapshot memory snapshot = priceSnapshots[index];
            
            if (snapshot.exists) {
                uint256 diff = snapshot.timestamp > timestamp 
                    ? snapshot.timestamp - timestamp 
                    : timestamp - snapshot.timestamp;
                
                if (diff < closestDiff) {
                    closestDiff = diff;
                    closestIndex = index;
                }
            }
        }
        
        if (closestIndex != type(uint256).max) {
            PriceSnapshot memory snapshot = priceSnapshots[closestIndex];
            return (snapshot.price, snapshot.exists);
        }
        
        return (0, false);
    }
    
    // ============ 价格变化计算 ============
    
    /**
     * @notice 计算价格涨跌幅（基于代币:USDT价格）
     * @return priceChangeBps 涨跌幅（基点），正数表示上涨，负数表示下跌
     */
    function getPriceChangeBps() external view override returns (int256) {
        uint256 currentPrice = getTokenCurrentPriceInUSDT();
        uint256 closePrice = this.getDailyClosePrice();
        
        if (closePrice == 0) {
            return 0;
        }
        
        // 计算涨跌幅（基点）
        if (currentPrice >= closePrice) {
            // 上涨
            uint256 change = ((currentPrice - closePrice) * 10000) / closePrice;
            return int256(change);
        } else {
            // 下跌
            uint256 change = ((closePrice - currentPrice) * 10000) / closePrice;
            return -int256(change);
        }
    }
    
    /**
     * @notice 计算价格涨跌幅绝对值
     */
    function getPriceChangeBpsAbs() external view override returns (uint256) {
        int256 change = this.getPriceChangeBps();
        return change < 0 ? uint256(-change) : uint256(change);
    }
    
    /**
     * @notice 计算滑点
     * @param currentPrice 当前交易价格
     * @param referencePrice 参考价格（通常是TWAP价格）
     * @return slippageBps 滑点（基点），正数表示价格上涨，负数表示价格下跌
     */
    function calculateSlippage(
        uint256 currentPrice,
        uint256 referencePrice
    ) external pure returns (int256 slippageBps) {
        if (referencePrice == 0) {
            return 0;
        }
        
        if (currentPrice >= referencePrice) {
            // 价格上涨
            uint256 change = ((currentPrice - referencePrice) * 10000) / referencePrice;
            return int256(change);
        } else {
            // 价格下跌
            uint256 change = ((referencePrice - currentPrice) * 10000) / referencePrice;
            return -int256(change);
        }
    }
    
    // ============ 信息查询函数 ============
    
    /**
     * @notice 获取追踪的代币信息
     */
    function getTrackedTokenInfo() external view override returns (
        address tokenAddress,
        address quoteTokenAddress,
        bool isToken0Tracked
    ) {
        return (
            trackedToken,
            quoteToken,
            pairInfo.isToken0Tracked
        );
    }
    
    /**
     * @notice 检查指定地址是否为当前追踪的代币
     */
    function isTrackedToken(address tokenAddress) external view override returns (
        bool isTracked,
        bool isToken0,
        bool isToken1
    ) {
        isTracked = (tokenAddress == trackedToken);
        isToken0 = (tokenAddress == pairInfo.token0Address);
        isToken1 = (tokenAddress == pairInfo.token1Address);
    }
    
    /**
     * @notice 验证池子配置
     */
    function verifyPairConfiguration() external view override returns (
        address pairAddress,
        address token0Address,
        address token1Address,
        address usdtAddress_,
        bool isToken0USDT_,
        address trackedToken_,
        string memory priceDirection
    ) {
        bool isToken0USDT = (pairInfo.token0Address == usdtAddress);
        string memory direction = pairInfo.isToken0Tracked 
            ? "token0/token1" 
            : "token1/token0";
        
        return (
            pairInfo.pairAddress,
            pairInfo.token0Address,
            pairInfo.token1Address,
            usdtAddress,
            isToken0USDT,
            trackedToken,
            direction
        );
    }
    
    /**
     * @notice 获取价格更新历史
     * @param count 返回的数量
     */
    function getPriceUpdateHistory(uint256 count) external view returns (
        uint256[] memory timestamps,
        uint256[] memory prices
    ) {
        uint256 length = count > snapshotCount ? snapshotCount : count;
        timestamps = new uint256[](length);
        prices = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            uint256 index = (oldestSnapshotIndex + snapshotCount - 1 - i) % MAX_SNAPSHOTS;
            PriceSnapshot memory snapshot = priceSnapshots[index];
            timestamps[i] = snapshot.timestamp;
            prices[i] = snapshot.price;
        }
    }
    
    // ============ 管理函数 ============
    
    /**
     * @notice 设置USDT地址
     */
    function setUSDTAddress(address _usdtAddress) external override onlyOwner {
        require(_usdtAddress != address(0), "Invalid USDT address");
        usdtAddress = _usdtAddress;
        emit USDTAddressSet(_usdtAddress);
    }
    
    /**
     * @notice 添加价格更新者（链下服务地址）
     */
    function addUpdater(address updater) external onlyOwner {
        require(updater != address(0), "Invalid updater address");
        updaters[updater] = true;
        emit UpdaterAdded(updater);
    }
    
    /**
     * @notice 移除价格更新者
     */
    function removeUpdater(address updater) external onlyOwner {
        updaters[updater] = false;
        emit UpdaterRemoved(updater);
    }
    
    /**
     * @notice 获取快照统计信息
     */
    function getSnapshotInfo() external view returns (
        uint256 count,
        uint256 oldestIndex,
        uint256 latestTimestamp,
        uint256 latestPrice
    ) {
        if (snapshotCount > 0) {
            uint256 latestIndex = (oldestSnapshotIndex + snapshotCount - 1) % MAX_SNAPSHOTS;
            PriceSnapshot memory latest = priceSnapshots[latestIndex];
            return (
                snapshotCount,
                oldestSnapshotIndex,
                latest.timestamp,
                latest.price
            );
        }
        return (0, 0, 0, 0);
    }
}

