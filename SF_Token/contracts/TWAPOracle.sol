// SPDX-License-Identifier: AGPL-3.0-only AND UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// File contracts/interface/ITWAPOracle.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ITWAPOracle
 * @notice TWAPOracle 合约接口，供其他合约调用
 */
interface ITWAPOracle {
    /**
     * @notice 获取每日收盘价
     * @return price 代币的价格（以USDT计价，18位精度）
     */
    function getDailyClosePrice() external view returns (uint256 price);
    
    /**
     * @notice 获取代币的每日收盘价（以USDT计价）
     * @return price 代币的价格（以USDT计价，18位精度）
     */
    function getTokenDailyClosePriceInUSDT() external view returns (uint256 price);
    
    /**
     * @notice 获取当前现货价格
     * @return price 当前价格（18位精度）
     */
    function getCurrentPrice() external view returns (uint256 price);
    
    /**
     * @notice 获取代币的当前价格（以USDT计价）
     * @return price 代币的当前价格（以USDT计价，18位精度）
     */
    function getTokenCurrentPriceInUSDT() external view returns (uint256 price);
    
    /**
     * @notice 计算价格涨跌幅（基于代币:USDT价格）
     * @return priceChangeBps 涨跌幅（基点），正数表示上涨，负数表示下跌
     */
    function getPriceChangeBps() external view returns (int256 priceChangeBps);
    
    /**
     * @notice 设置USDT地址
     * @param _usdtAddress USDT代币地址
     */
    function setUSDTAddress(address _usdtAddress) external;
}


// File solmate/src/auth/Owned.sol@v6.8.0

// Original license: SPDX_License_Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}


// File contracts/TWAPOracle.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;



/**
 * @title TWAPOracle
 * @notice 简化版价格预言机，支持链下更新每日收盘价
 * @dev 用于计算价格涨跌幅，供SFK合约使用
 */
contract TWAPOracle is ITWAPOracle, Owned {
    // ============ 存储结构 ============
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
    
    // 每日收盘价
    uint256 public lastDailyClosePrice;          // 最后一次每日收盘价
    uint256 public lastDailyCloseDay;            // 最后一次每日收盘的日期
    
    // 管理员权限
    mapping(address => bool) public admins;
    
    // ============ 事件 ============
    
    event DailyClosePriceUpdated(uint256 day, uint256 price);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event USDTAddressSet(address indexed usdtAddress);
    event PairInfoUpdated(address indexed pairAddress, address token0, address token1, bool isToken0Tracked);
    
    // ============ 修饰符 ============
    
    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner, "Not authorized admin");
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
    }
    
    // ============ 价格更新函数（链下调用） ============
    
    /**
     * @notice 更新每日收盘价（由管理员调用）
     * @dev 每天只能更新一次，如果今天已经更新过则不会再次更新
     * @dev 注意：当前价格可能被闪电贷操纵，建议在流动性充足且价格稳定时更新
     */
    function updateDailyClosePrice() external onlyAdmin {
        uint256 currentDay = block.timestamp / 1 days;
        
        // 如果今天还没有更新过，或者已经过了新的一天
        if (lastDailyCloseDay < currentDay) {
            // 获取当前价格作为收盘价
            uint256 currentPrice = getTokenCurrentPriceInUSDT();
            require(currentPrice > 0, "Invalid current price");
            
            lastDailyClosePrice = currentPrice;
            lastDailyCloseDay = currentDay;
            
            emit DailyClosePriceUpdated(currentDay, currentPrice);
        }
    }
    
    /**
     * @notice 手动设置每日收盘价（由管理员调用）
     * @param price 收盘价（18位精度）
     * @param day 日期（timestamp / 1 days）
     * @dev 允许随时手动设置，用于特殊情况或数据修正
     */
    function setDailyClosePrice(uint256 price, uint256 day) external onlyAdmin {
        require(price > 0, "Invalid price");
        require(day > 0, "Invalid day");
        
        lastDailyClosePrice = price;
        lastDailyCloseDay = day;
        
        emit DailyClosePriceUpdated(day, price);
    }
    
    // ============ 价格查询函数 ============
    
    /**
     * @notice 获取当前现货价格（从交易对直接读取）
     * @dev 警告：此价格可能被闪电贷攻击操纵，仅用于参考
     * @dev 建议在流动性充足时使用，或使用TWAP价格
     */
    function getCurrentPrice() external view override returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairInfo.pairAddress);
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        
        require(reserve0 > 0 && reserve1 > 0, "No liquidity");
        
        if (pairInfo.isToken0Tracked) {
            // token0是被追踪的代币，价格 = reserve1 / reserve0
            return (uint256(reserve1) * 1e18) / reserve0;
        } else {
            // token1是被追踪的代币，价格 = reserve0 / reserve1
            return (uint256(reserve0) * 1e18) / reserve1;
        }
    }
    
    /**
     * @notice 获取代币的当前价格（以USDT计价）
     */
    function getTokenCurrentPriceInUSDT() public view override returns (uint256) {
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
     * @notice 获取代币的每日收盘价（以USDT计价）
     */
    function getTokenDailyClosePriceInUSDT() external view override returns (uint256) {
        return this.getDailyClosePrice();
    }
    
    // ============ 价格变化计算 ============
    
    /**
     * @notice 计算价格涨跌幅（基于代币:USDT价格）
     * @return priceChangeBps 涨跌幅（基点），正数表示上涨，负数表示下跌
     * @dev 如果当前价格或收盘价为0，返回0以避免除零错误
     */
    function getPriceChangeBps() external view override returns (int256) {
        uint256 currentPrice = getTokenCurrentPriceInUSDT();
        uint256 closePrice = this.getDailyClosePrice();
        
        if (closePrice == 0 || currentPrice == 0) {
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
    
    // ============ 信息查询函数 ============
    
    /**
     * @notice 获取交易对信息
     * @return pairAddress 交易对地址
     * @return token0Address token0地址
     * @return token1Address token1地址
     * @return isToken0Tracked 追踪的代币是否为token0
     */
    function getPairInfo() external view returns (
        address pairAddress,
        address token0Address,
        address token1Address,
        bool isToken0Tracked
    ) {
        return (
            pairInfo.pairAddress,
            pairInfo.token0Address,
            pairInfo.token1Address,
            pairInfo.isToken0Tracked
        );
    }
    
    // ============ 管理函数 ============
    
    /**
     * @notice 设置交易对信息（由owner调用）
     * @param _pairAddress 新的交易对地址
     * @dev 验证新的交易对是否包含被追踪的代币
     * @dev 注意：更改交易对地址可能影响价格计算的准确性
     */
    function setPairInfo(address _pairAddress) external onlyOwner {
        require(_pairAddress != address(0), "Invalid pair address");
        
        // 获取交易对信息
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);
        address token0 = pair.token0();
        address token1 = pair.token1();
        
        require(token0 != address(0) && token1 != address(0), "Invalid pair tokens");
        
        bool isToken0Tracked = (token0 == trackedToken);
        require(
            (token0 == trackedToken || token1 == trackedToken),
            "Tracked token not in pair"
        );
        
        // 验证交易对是否有流动性
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        require(reserve0 > 0 && reserve1 > 0, "Pair has no liquidity");
        
        pairInfo = PairInfo({
            pairAddress: _pairAddress,
            token0Address: token0,
            token1Address: token1,
            isToken0Tracked: isToken0Tracked
        });
        
        emit PairInfoUpdated(_pairAddress, token0, token1, isToken0Tracked);
    }
    
    /**
     * @notice 设置USDT地址
     */
    function setUSDTAddress(address _usdtAddress) external override onlyOwner {
        require(_usdtAddress != address(0), "Invalid USDT address");
        usdtAddress = _usdtAddress;
        emit USDTAddressSet(_usdtAddress);
    }
    
    /**
     * @notice 添加管理员
     */
    function addAdmin(address admin) external onlyOwner {
        require(admin != address(0), "Invalid admin address");
        admins[admin] = true;
        emit AdminAdded(admin);
    }
    
    /**
     * @notice 移除管理员
     */
    function removeAdmin(address admin) external onlyOwner {
        admins[admin] = false;
        emit AdminRemoved(admin);
    }
}
