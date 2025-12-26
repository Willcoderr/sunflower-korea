// Sources flattened with hardhat v2.27.1 https://hardhat.org

// SPDX-License-Identifier: AGPL-3.0-only AND MIT AND UNLICENSED

// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol@v1.1.0-beta.0

pragma solidity >=0.8.20 <0.8.25;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol@v1.1.0-beta.0

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/Const.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

// 主网
// address constant _USDT = 0x55d398326f99059fF775485246999027B3197955; // USDT
// address constant _SF = 0x8b07a652203905240a3b9759627f17d6e8F14994; // SF Token
// address constant _ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router
// address constant FUND_ADDRESS = 0xb966801b01b3EE8DafB0e4cf0FbDa5fEbC0FA1F7; // Fund Address

address constant _USDT = 0xC6961C826cAdAC9b85F444416D3bf0Ca2a1c38CA; // MUSDT
address constant _SF = 0x9af8d66Fc14beC856896771fD7D2DB12b41ED9E8; // SF Token
address constant _SFK = 0xb362f8372cE0EF2265E9988292d17abfEB96473f; // SFK Token
address constant _ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PancakeSwap Router
address constant FUND_ADDRESS = 0xf3A51876c0Fb4FA7F99A62E3D6CF7d0574Aeb60d; // Fund Address (测试用 Owner 地址)


// File contracts/interface/ISF.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ISFErc20 {
    event ExcludedFromFee(address account);
    event IncludedToFee(address account);
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    function allowance(address, address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function decimals() external view returns (uint8);
    function distributor() external view returns (address);
    function dividendToUsersLp() external;
    function excludeFromDividend(address account) external;
    function excludeFromFee(address account) external;
    function excludeMultipleAccountsFromFee(address[] memory accounts) external;
    // function getInviter(address user) external view returns (address);
    function inSwapAndLiquify() external view returns (bool);
    function includeInFee(address account) external;
    function isDividendExempt(address) external view returns (bool);
    function isExcludedFromFee(address account) external view returns (bool);
    function isInShareholders(address) external view returns (bool);
    function isPreacher(address user) external view returns (bool);
    function is200Pair(address user) external  view returns (bool);
    function lastLPFeefenhongTime() external view returns (uint256);
    function launchedAtTimestamp() external view returns (uint40);
    function minDistribution() external view returns (uint256);
    function minPeriod() external view returns (uint256);
    function name() external view returns (string memory);
    function owner() external view returns (address);
    function presale() external view returns (bool);
    function setDistributorGasForLp(uint256 _distributorGasForLp) external;
    function setMinDistribution(uint256 _minDistribution) external;
    function setMinPeriod(uint256 _minPeriod) external;
    function setPresale() external;
    function shareholderIndexes(address) external view returns (uint256);
    function shareholders(uint256) external view returns (address);
    function symbol() external view returns (string memory);
    function tOwnedU(address user) external view returns (uint256 totalUbuy);
    function transferOwnership(address newOwner) external;
    function uniswapV2Pair() external view returns (address);
    function recycle(uint256 amount) external;
    // function setInvite(address user, address parent) external;
    // function inviter(address user) external view returns (address parent);
    function getReserveU() external view returns (uint112);

    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File contracts/interface/ISFExchange.sol

// Original license: SPDX_License_Identifier: UNLICENSED
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
    event SfSwapAddressUpdated(address indexed oldAddress, address indexed newAddress);
    event UsdtSwapAddressUpdated(address indexed oldAddress, address indexed newAddress);
    
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
     * @return _minSFReserve 最小 SF 储备
     * @return _minUSDTReserve 最小 USDT 储备
     * @return _stakingContract 质押合约地址
     * @return _sfSwapAddress SF 交换地址
     * @return _usdtSwapAddress USDT 交换地址
     */
    function getConfig() external view returns (
        uint256 _minSFReserve,
        uint256 _minUSDTReserve,
        address _stakingContract,
        address _sfSwapAddress,
        address _usdtSwapAddress
    );
}


// File solmate/src/auth/Owned.sol

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


// File contracts/SFExchange.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

/**
 * @title SF Exchange Contract (中间合约)
 * @notice 白名单地址无税购买 SF 后存入，供质押合约使用
 * 
 * 核心功能：
 * 1. 白名单充值 SF（链下购买后转入）
 * 2. 接收 USDT，转出 SF（给质押用户，无税）
 * 3. 接收 SF，转出 USDT（解押时回收 SF）
 * 4. 动态兑换比例（基于 SF/USDT 池价格）
 * 5. 储备金管理（USDT 和 SF 余额监控）
 */







contract SFExchange is ISFExchange, Owned, ReentrancyGuard {
    ISFErc20 public SF = ISFErc20(_SF);
    IERC20 public USDT = IERC20(_USDT);
    IERC20 public SFK = IERC20(_SFK);
    IUniswapV2Router02 public immutable ROUTER = IUniswapV2Router02(_ROUTER);

    address public stakingContract;  // 只允许质押合约调用
    address public sfSwapAddress;    // SF白名单地址（用于接收USDT并购买SF）
    address public usdtSwapAddress;  // USDT补充地址 (用于接收SF并购买USDT）
    
    uint256 public minSFReserve = 10e18;  // 最小 SF 储备
    uint256 public minUSDTReserve = 500e18; // 最小 USDT 储备
    
    constructor() Owned(msg.sender) {
        // 验证 SF 合约配置正确
        address pairAddress = SF.uniswapV2Pair();
        require(pairAddress != address(0), "SF pair not configured");
    }
    
    modifier onlyStaking() {
        require(msg.sender == stakingContract, "Only staking");
        _;
    }
    
    /**
     * @dev 质押时：USDT → SF（无税）
     * @param usdtAmount USDT 数量
     * @return sfAmount 返回的 SF 数量
     */
    function exchangeUSDTForSF(uint256 usdtAmount) external override onlyStaking nonReentrant returns (uint256 sfAmount) {
        require(usdtAmount > 0, "Amount must be greater than 0");

        // 1. 接收 USDT
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        
        // 2. 基于当前价格计算 SF 数量（参考 SF/USDT 池）
        sfAmount = calculateSFAmount(usdtAmount);
        
        // 3. 检查 SF 储备是否充足
        require(SF.balanceOf(address(this)) >= sfAmount + minSFReserve, "Insufficient SF reserve");

        // 4. 转出 SF
        SF.transfer(msg.sender, sfAmount);

        // 5. 将 USDT 转给 sfSwapAddress（用于购买SF补充储备）
        require(sfSwapAddress != address(0), "sfSwapAddress not set");
        USDT.transfer(sfSwapAddress, usdtAmount);

        emit ExchangeUSDTForSF(msg.sender, usdtAmount, sfAmount);
    }
    
    /**
     * @dev 解押时：SF → USDT
     * @param sfAmount SF 数量
     * @return usdtAmount 返回的 USDT 数量
     */
    function exchangeSFForUSDT(uint256 sfAmount) external override onlyStaking nonReentrant returns (uint256 usdtAmount) {
        require(sfAmount > 0, "Amount must be greater than 0");

        // 1. 接收 SF
        SF.transferFrom(msg.sender, address(this), sfAmount);

        // 2. 基于当前价格计算 USDT 数量
        usdtAmount = calculateUSDTAmount(sfAmount);
        
        // 3. 检查 USDT 储备是否充足
        require(USDT.balanceOf(address(this)) >= usdtAmount + minUSDTReserve, "Insufficient USDT reserve");

       // 4. 转出 USDT
        USDT.transfer(msg.sender, usdtAmount);

        // 5. 将 SF 转给 usdtSwapAddress（用于购买USDT补充储备）
        require(usdtSwapAddress != address(0), "usdtSwapAddress not set");
        SF.transfer(usdtSwapAddress, sfAmount);

        emit ExchangeSFForUSDT(msg.sender, sfAmount, usdtAmount);
    }
    
    /**
     * @dev 白名单充值（链下购买后转入）
     */
    function depositFromWhitelist(uint256 sfAmount, uint256 usdtAmount) external override onlyOwner nonReentrant {
        require(sfAmount > 0 || usdtAmount > 0, "At least one amount must be greater than 0");
        if (sfAmount > 0) {
            SF.transferFrom(msg.sender, address(this), sfAmount);
        }
        if (usdtAmount > 0) {
            USDT.transferFrom(msg.sender, address(this), usdtAmount);
        }
        emit WhitelistDeposit(msg.sender, sfAmount, usdtAmount);
    }

    /**
     * @dev 设置SF白名单地址
     * @param _sfSwapAddress SF白名单地址（用于接收USDT并购买SF）
     */
    function setSfSwapAddress(address _sfSwapAddress) external onlyOwner {
        require(_sfSwapAddress != address(0), "Invalid address");
        address oldAddress = sfSwapAddress;
        sfSwapAddress = _sfSwapAddress;
        emit SfSwapAddressUpdated(oldAddress, _sfSwapAddress);
    }

    /**
     * @dev 设置USDT补充地址
     * @param _usdtSwapAddress USDT补充地址（用于接收SF并购买USDT）
     */
    function setUsdtSwapAddress(address _usdtSwapAddress) external onlyOwner {
        require(_usdtSwapAddress != address(0), "Invalid address");
        address oldAddress = usdtSwapAddress;
        usdtSwapAddress = _usdtSwapAddress;
        emit UsdtSwapAddressUpdated(oldAddress, _usdtSwapAddress);
    }
    
    /**
     * @dev 设置质押合约地址
     */
    function setStakingContract(address _stakingContract) external override onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        address oldContract = stakingContract;
        stakingContract = _stakingContract;
        emit StakingContractUpdated(oldContract, _stakingContract);
    }
    
    /**
     * @dev 设置最小储备金阈值
     */
    function setReserveThresholds(uint256 _minSFReserve, uint256 _minUSDTReserve) external override onlyOwner {
        require(_minSFReserve <= type(uint256).max / 2, "minSFReserve too large");
        require(_minUSDTReserve <= type(uint256).max / 2, "minUSDTReserve too large");
        minSFReserve = _minSFReserve;
        minUSDTReserve = _minUSDTReserve;
        emit ReserveThresholdUpdated(_minSFReserve, _minUSDTReserve);
    }
    
    /**
     * @dev 紧急提取（仅 owner）
     */
    function emergencyWithdraw(address token, uint256 amount, address to) external override onlyOwner nonReentrant {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient");
        require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient contract balance");
        IERC20(token).transfer(to, amount);
    }
    
    /**
     * @dev 计算兑换价格（使用 Uniswap Router）
     * @param usdtAmount USDT 数量
     * @return SF 数量（已自动处理 token 顺序、滑点和手续费）
     */
    function calculateSFAmount(uint256 usdtAmount) public view override returns (uint256) {
        require(usdtAmount > 0, "Amount must be greater than 0");
        
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SF);
        
        uint256[] memory amountsOut = ROUTER.getAmountsOut(usdtAmount, path);
        return amountsOut[1];
    }
    
    /**
     * @dev 计算反向兑换价格（使用 Uniswap Router）
     * @param sfAmount SF 数量
     * @return USDT 数量（已自动处理 token 顺序、滑点和手续费）
     */
    function calculateUSDTAmount(uint256 sfAmount) public view override returns (uint256) {
        require(sfAmount > 0, "Amount must be greater than 0");
        
        address[] memory path = new address[](2);
        path[0] = address(SF);
        path[1] = address(USDT);
        
        uint256[] memory amountsOut = ROUTER.getAmountsOut(sfAmount, path);
        return amountsOut[1];
    }
    
    /**
     * @dev 查询储备金状态
     */
    function getReserveStatus() external view override returns (
        uint256 sfBalance,
        uint256 usdtBalance,
        bool sfSufficient,
        bool usdtSufficient
    ) {
        sfBalance = SF.balanceOf(address(this));
        usdtBalance = USDT.balanceOf(address(this));
        sfSufficient = sfBalance >= minSFReserve;
        usdtSufficient = usdtBalance >= minUSDTReserve;
    }
    
    /**
     * @dev 获取配置参数
     */
    function getConfig() external view override returns (
        uint256 _minSFReserve,
        uint256 _minUSDTReserve,
        address _stakingContract,
        address _sfSwapAddress,
        address _usdtSwapAddress
    ) {
        _minSFReserve = minSFReserve;
        _minUSDTReserve = minUSDTReserve;
        _stakingContract = stakingContract;
        _sfSwapAddress = sfSwapAddress;
        _usdtSwapAddress = usdtSwapAddress;
    }
}
