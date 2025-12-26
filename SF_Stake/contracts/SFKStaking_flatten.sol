

[dotenv@17.2.3] injecting env (4) from .env -- tip: ⚙️  specify custom .env file path with { path: '/custom/path/.env' }
// Sources flattened with hardhat v2.27.1 https://hardhat.org

// SPDX-License-Identifier: AGPL-3.0-only AND MIT AND UNLICENSED

// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol@v1.1.0-beta.0

pragma solidity >=0.6.2;

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


// File @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol@v1.0.1

pragma solidity >=0.5.0;

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


// File contracts/Const.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

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

    function exchangeUSDTForSF(uint256 usdtAmount) external returns (uint256 sfAmount);
    function exchangeSFForUSDT(uint256 sfAmount) external returns (uint256 usdtAmount);
    function depositFromWhitelist(uint256 sfAmount, uint256 usdtAmount) external;
    function setStakingContract(address _stakingContract) external;
    function setReserveThresholds(uint256 _minSFReserve, uint256 _minUSDTReserve) external;
    function emergencyWithdraw(address token, uint256 amount, address to) external;
    function calculateSFAmount(uint256 usdtAmount) external view returns (uint256);
    function calculateUSDTAmount(uint256 sfAmount) external view returns (uint256);
    function getReserveStatus() external view returns (
        uint256 sfBalance,
        uint256 usdtBalance,
        bool sfSufficient,
        bool usdtSufficient
    );
}


// File contracts/interface/ISFK.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ISFK {
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
    function recycleUSDT(uint256 amount) external;
    function recycleSF(uint256 amount) external;
    // function setInvite(address user, address parent) external;
    // function inviter(address user) external view returns (address parent);
    function getReserveUSDT() external view returns (uint112);
    function getReserveSF() external view returns (uint112);

    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File contracts/interface/IStakingReward.sol

// Original license: SPDX_License_Identifier: UNLICENSED
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


// File contracts/SFKStaking.sol

/**
 *Submitted for verification at BscScan.com on 2025-10-11
*/

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;










library Math {
    function min(uint40 a, uint40 b) internal pure returns (uint40) {
        return a < b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

abstract contract Referral{
    mapping(address => address) private _parentOf;
    mapping(address => bool) private _isBound;
    mapping(address => uint256) private _directCount;
    address[] private _allUsers;
    address private _root;
    event BindReferral(address indexed user,address parent);
    constructor() {
        _root = msg.sender;
        _isBound[_root] = true;   
        _parentOf[_root] = address(0); 
        _allUsers.push(_root);
    }

    function getReferral(address _address) public view returns(address) {
        return _parentOf[_address];
    }
    function isBindReferral(address _address) public view returns(bool) {
        return _isBound[_address];
    }

    function getReferralCount(address _address) public view returns(uint256) {
        return _directCount[_address];
    }

    function bindReferral(address _referral, address _user) internal {
        require(_user != address(0) && _referral != address(0), "ZERO");
        require(_user != _referral, "SELF");
        require(!_isBound[_user], "BOUND");
        require(_isBound[_referral], "PARENT_NOT_BOUND");

        _parentOf[_user] = _referral;
        _isBound[_user] = true;
        _allUsers.push(_user);
        unchecked { _directCount[_referral] += 1; }

        emit BindReferral(_user, _referral);
    }

    function getReferrals(address _address, uint256 _num)public view returns(address[] memory) {
        address[] memory ups = new address[](_num);
        address cur = _parentOf[_address];
        uint256 i = 0;
        while (cur != address(0) && i < _num) {
            ups[i] = cur;
            unchecked { i++; }
            cur = _parentOf[cur];
        }
        if (i < _num) {
            assembly { mstore(ups, i) }
        }
        return ups;
    }

    function getRootAddress() public view returns(address) {
        return _root;
    }
    function getUsersCount() public view returns(uint256) {
        return _allUsers.length;
    }

    function getUsers(uint256 fromId,uint256 toId) public view returns ( address[] memory addrArr ) {
        require(fromId <= toId, "fromId > toId");
        require(toId <= _allUsers.length, "exist num!");
        require(fromId <= _allUsers.length, "exist num!");
        addrArr = new address[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            addrArr[i] = _allUsers[ith];
            i = i+1;
        }
        return (addrArr);
    }
}

contract Staking is Referral,Owned,ReentrancyGuard {
    event Staked( address indexed user,  uint256 amount,  uint256 timestamp, uint256 index, uint256 stakeTime);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Unstake(address indexed user,uint256 reward,uint40 timestamp,uint256 index);
    event RewardOnly(address indexed user,uint256 reward,uint40 timestamp,uint256 index);
    event UnstakeSFToWhitelist(address indexed user, uint256 sfAmount, uint256 expectedUsdtValue, uint256 actualUsdtGot, uint40 timestamp);
    event ExchangeReserveLow(address indexed token, uint256 currentReserve, uint256 requiredReserve, uint40 timestamp);
    event NewReferralReward(address indexed user, address indexed referral, uint256 reward, uint256 generation, uint40 timestamp);
    event NewTeamReward(address indexed user, uint256 level, uint256 reward, uint40 timestamp);
    // event RankingReward(address indexed user, uint256 rewardType, uint256 reward, uint40 timestamp);
    event TeamLevelUpdated(address indexed user, uint256 previousLevel, uint256 newLevel, uint256 kpi, uint40 timestamp);
    
    // 收益率配置：1天期每天0.3%，15天期每天0.6%，30天期每天1.3%
    // 每秒复利因子计算：(1 + 日收益率)^(1/86400)
    uint256[3] rates = [1000000003463000000,1000000006917000000,1000000014950000000];
    uint256[3] stakeDays = [1 days, 15 days, 30 days];
    uint40 public constant timeStep = 1 days;

    IUniswapV2Router02 constant ROUTER = IUniswapV2Router02(_ROUTER);
    IERC20 constant USDT = IERC20(_USDT);

    ISFErc20 public SF;
    ISFK public SFK;

    ISFExchange public sfExchange;  // 中间合约
    IStakingReward public stakingReward;  // 奖励分配合约

    address constant addressProfitUser = 0x5E77DEEe08b98881fdd4eDB3642fEAB78C443C42;
    address constant addressProfit2NFT = 0xD3da2a27DFCb59e002727B0E0EffEe1ddC732aaE;
    address constant addressProfit2Team = 0x246C829bF0A8ACaF802dB52d7894605B4C4f1E59;
    address constant addressProfit2V5 = 0x341625c5D89f161f1EEF35D2b110fC096A42AeFB;
    address constant fundAddress = 0x485199875526eC576838967207af1B8624C9F1d1;
    address constant profitAddress = 0xa65d295c38133f1a2FdfcA674712FdEEcc839aE9;  // 盈利税地址（用于回购销毁）

    address constant sfSwapAddress = 0x0047ebb57DB94aa193289258d48BA62f43bb8c60; // sf 白名单地址

    // EOA地址提取相关状态变量
    address public eoaWithdrawAddress;  // EOA地址（可配置，由owner设置）
 
    uint8 public constant decimals = 18;
    string public constant name = "ComToken";
    string public constant symbol = "ComToken";

    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public userIndex;

    mapping(address => uint256) public upProfitSum;
    mapping(address => uint256) public teamProfitSum;

    mapping(address => Record[]) public userStakeRecord;
    mapping(address => uint256) public teamTotalInvestValue;
    mapping(address => uint256) public teamVirtuallyInvestValue;

    uint8 constant maxD = 2;

    RecordTT[] public t_supply;
    uint256 public mMinSwapRatioUsdt = 50;//100
    uint256 public mMinSwapRatioToken = 50;//100
    uint256 startTime=0;
    uint256 constant network1InTime=90 days;
    bool bStart = false;
    
    mapping(uint256 => uint256) public tenSecondStakeAmount;  // bucketIndex => 该10秒的累计质押量
    uint256 public lastUpdatedBucket;

    struct RecordTT {
        uint40 stakeTime;
        uint160 tamount;
    }

    struct Record {
        uint40 oriStakeTime;
        uint40 stakeTime;
        uint160 amount;
        bool status;
        uint8 stakeIndex;
    }

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "EOA");
        _;
    }

    constructor() Owned(msg.sender) {
        USDT.approve(address(ROUTER), type(uint256).max);
    }

    function setSF(address _sf) external onlyOwner {
        SF = ISFErc20(_sf);
        SF.approve(address(ROUTER), type(uint256).max);
    }

    function setSFK(address _sfk) external onlyOwner {
        SFK = ISFK(_sfk);
        SFK.approve(address(ROUTER), type(uint256).max);
    }

    function setSFExchange(address _sfExchange) external onlyOwner {
        require(_sfExchange != address(0), "Invalid address");
        sfExchange = ISFExchange(_sfExchange);
        USDT.approve(_sfExchange, type(uint256).max);
        SF.approve(_sfExchange, type(uint256).max);
    }
    
    function setStakingReward(address _stakingReward) external onlyOwner {
        require(_stakingReward != address(0), "Invalid address");
        stakingReward = IStakingReward(_stakingReward);
    }

    function getNowTIme() external view returns(uint256){
        return block.timestamp;
    }
    function setEoaWithdrawAddress(address _eoaAddress) external onlyOwner {
        eoaWithdrawAddress = _eoaAddress;
    }

    function getParameters(address account) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(20));
        uint256 ith=0;
        paraList[ith]=0; if(bStart&&block.timestamp>startTime ) paraList[ith]=1;ith=ith+1;
        paraList[ith]=startTime;ith=ith+1;
        paraList[ith]=totalSupply;ith=ith+1;
        paraList[ith]=balances[account];ith=ith+1;
        paraList[ith]=balanceOf(account);ith=ith+1;
        paraList[ith]=maxStakeAmount();ith=ith+1;
        paraList[ith]=userStakeRecord[account].length;ith=ith+1;
        paraList[ith]=getTeamKpi(account);ith=ith+1;
        paraList[ith]=0;if(isPreacher(account)) paraList[ith]=1;ith=ith+1;
        paraList[ith]=0;if(isBindReferral(account)) paraList[ith]=1;ith=ith+1;
        paraList[ith]=upProfitSum[account];ith=ith+1;
        paraList[ith]=teamProfitSum[account];ith=ith+1;

        return paraList;
    }
    function balanceOf(address account)public view returns (uint256 balance){
        Record[] storage cord = userStakeRecord[account];
        if (cord.length > 0) {
            for (uint256 i = cord.length - 1; i >= 0; i--) {
                Record storage user_record = cord[i];
                if (!user_record.status) {
                    balance += caclItem(user_record);
                }
                if (i == 0) break;
            }
        }
    }
    /**
     * @dev 更新当前10秒桶的质押量累加器
     * @param amount 新增的质押量
     */
    function _updateMinuteStakeAmount(uint256 amount) private {
        // 计算当前10秒桶索引（10秒级别，向下取整）
        // 例如：10:01:35 → bucketIndex = 10:01:35 / 10 = 6001
        uint256 currentBucket = block.timestamp / 10 seconds;
        
        // 累加到对应10秒桶的累计量
        tenSecondStakeAmount[currentBucket] += amount;
        lastUpdatedBucket = currentBucket;
    }
    
    function network1In() public view returns (uint256 value) {
        if(block.timestamp > startTime+network1InTime) {
            return 0 ether;
        }
        
        // 计算滑动窗口：当前时间 - 1分钟 到 当前时间
        uint256 windowStart = block.timestamp - 1 minutes;
        uint256 windowEnd = block.timestamp;
        
        // 计算窗口涉及的10秒桶索引
        uint256 startBucket = windowStart / 10 seconds;
        uint256 endBucket = windowEnd / 10 seconds;
        
        // 滑动窗口最多跨越6-7个10秒桶（60秒窗口）        
        value = 0;
        for (uint256 bucket = startBucket; bucket <= endBucket; bucket++) {
            value += tenSecondStakeAmount[bucket];
        }
        
        return value;
    }
    function canStakeAmount() public view returns (uint256) {
        uint256 amout0=0;
        if(startTime==0) return amout0;
        if(block.timestamp < startTime) return amout0;

        // 计算经过了多少个24小时
        uint256 daysElapsed = (block.timestamp - startTime) / 1 days;
        
        // 初始200U，每24小时递增100U
        amout0 = 200 ether + daysElapsed * (100 ether);

        if(amout0 > 2000 ether) amout0 = 2000 ether;
        return amout0;
    }

    function maxStakeAmount() public view returns (uint256) {
        uint256 lastIn = network1In();  // 最近1分钟的入场量
        uint256 canStakV = canStakeAmount();  // 每分钟可入场额度
        
        // 如果最近1分钟入场量超过额度，返回0
        if(lastIn > canStakV) return 0;
        
        // 计算剩余可入场额度
        uint256 remaining = canStakV - lastIn;
        
        // 获取底池USDT储备
        uint256 reverseu = SFK.getReserveUSDT();
        uint256 sfReserve = SFK.getReserveSF(); // 获取池子里边有多少SF
        uint256 usdtOut = quoteSFInUSDT(sfReserve); // SF转换成USDT
        reverseu = reverseu + usdtOut ;
        
        // 如果已达到2000U上限，使用底池0.2%的逻辑
        if(canStakV >= 2000 ether) {
            // 计算底池的0.2% (reverseu * 2 / 1000 = reverseu / 500)
            uint256 poolLimit = reverseu / 500;
            
            // 如果底池0.2% < 2000U，按2000U来
            if(poolLimit < 2000 ether) {
                poolLimit = 2000 ether;
            }
            
            // 取剩余额度与底池限制的较小值
            if(remaining > poolLimit) {
                remaining = poolLimit;
            }
        } else {
            // 未达到2000U时，使用底池的0.2%
            uint256 p1 = reverseu / 500;  // 底池的0.2%
            if(remaining > p1) {
                remaining = p1;
            }
        }
        
        return remaining;
    }

     //两跳：SF -> SFK -> USDT，避免直接 SF/USDT 没池子
     function quoteSFInUSDT(uint256 sfAmount) public view returns (uint256 usdtOut) {
         if (sfAmount == 0) return 0;
         address[] memory path = new address[](3);
         path[0] = address(SF);
         path[1] = address(SFK);
         path[2] = address(USDT);
         uint256[] memory amountsOut = ROUTER.getAmountsOut(sfAmount, path);
         return amountsOut[2];
    }

    //uint8 最大 255，用户记录最多200条，所以使用uint256不会越界
    function rewardOfSlot(address user, uint256 index) public view returns (uint256 reward){
        Record storage user_record = userStakeRecord[user][index];
        return caclItem(user_record);
    }


    function getTeamKpi(address _user) public view returns (uint256) {
        return teamTotalInvestValue[_user] + teamVirtuallyInvestValue[_user];
    }
    function getTeamInfos(address[] memory addrArr) external view returns (
        uint256[] memory kpiArr,
        uint256[] memory balancesArr,
        bool[] memory isPreacherArr,
        bool[] memory isV5Arr
        ) {
        kpiArr = new uint256[](addrArr.length);
        balancesArr = new uint256[](addrArr.length);
        isPreacherArr = new bool[](addrArr.length);
        isV5Arr = new bool[](addrArr.length);
        for(uint256 i=0; i<addrArr.length; i++) {
            kpiArr[i] = getTeamKpi(addrArr[i]);
            balancesArr[i] = balances[addrArr[i]];
            isPreacherArr[i] = isPreacher(addrArr[i]);
            isV5Arr[i] = (kpiArr[i]>500000 *10**18);
        }
        return (kpiArr,balancesArr,isPreacherArr,isV5Arr);
    }
    //布道者要求：余额 ≥ 200 USDT
    function isPreacher(address user) public view returns (bool) {
        return balances[user] >= 200e18;
    }
    function userStakeCount(address user) external view returns (uint256 count) {
        count = userStakeRecord[user].length;
    }

    // 计算单个质押记录的详细信息
    function _getStakeRecordInfo(Record storage user_record, uint256 currentTime) private view returns (
        uint256 reward,
        uint256 canEndData,
        bool bEndData
    ) {
        if (!user_record.status) {
            reward = caclItem(user_record);
        }
        canEndData = user_record.oriStakeTime + stakeDays[user_record.stakeIndex];
        bEndData = canEndData < currentTime;
    }

    function userStakeInfo(address user, uint8 index) external view returns (
        uint256 oriStakeTime,
        uint256 stakeTime,
        uint256 amount,
        bool status,
        uint256 stakeIndex,
        uint256 reward,
        uint256 canEndData,
        bool bEndData
        ) {
        Record storage user_record = userStakeRecord[user][index];
        oriStakeTime =  uint256(user_record.oriStakeTime);
        stakeTime = uint256(user_record.stakeTime);
        amount = uint256(user_record.amount);
        status = user_record.status;
        stakeIndex = uint256(user_record.stakeIndex);
        (reward, canEndData, bEndData) = _getStakeRecordInfo(user_record, block.timestamp);
    }
    function userStakeInfos(address user) external view returns (
        uint256[] memory oriStakeTimeArr,
        uint256[] memory stakeTimeArr,
        uint256[] memory amountArr,
        bool[] memory statusArr,
        uint256[] memory stakeIndexArr,
        uint256[] memory rewardArr,
        uint256[] memory canEndDataArr,
        bool[] memory bEndDataArr
        ) {

        Record[] storage cord = userStakeRecord[user];
        if (cord.length <= 0) 
            return (oriStakeTimeArr,stakeTimeArr,amountArr,statusArr,stakeIndexArr,rewardArr,canEndDataArr,bEndDataArr);
        oriStakeTimeArr = new uint256[](cord.length);
        stakeTimeArr = new uint256[](cord.length);
        amountArr = new uint256[](cord.length);
        statusArr = new bool[](cord.length);
        stakeIndexArr = new uint256[](cord.length);
        rewardArr = new uint256[](cord.length);
        canEndDataArr = new uint256[](cord.length);
        bEndDataArr = new bool[](cord.length);
        uint256 nowTime = block.timestamp;
        for (uint256 i = 0; i<cord.length ; i++) {
            Record storage user_record = cord[i];
            oriStakeTimeArr[i] =  uint256(user_record.oriStakeTime);
            stakeTimeArr[i] =  uint256(user_record.stakeTime);
            amountArr[i] =  uint256(user_record.amount);
            statusArr[i] =  user_record.status;
            stakeIndexArr[i] =  uint256(user_record.stakeIndex);
            (rewardArr[i], canEndDataArr[i], bEndDataArr[i]) = _getStakeRecordInfo(user_record, nowTime);
        }
        return (oriStakeTimeArr,stakeTimeArr,amountArr,statusArr,stakeIndexArr,rewardArr,canEndDataArr,bEndDataArr);
    }
    function allRecordLength() external view returns (uint256 allRecordLen ) {
        allRecordLen = t_supply.length;
    }
    function allRecordInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory timeArr,
        uint256[] memory amountArr) {
        require(fromId <= toId, "fromId > toId");
        require(toId < t_supply.length, "toId out of range");
        timeArr = new uint256[](toId-fromId+1);
        amountArr = new uint256[](toId-fromId+1);

        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            timeArr[i] = uint256(t_supply[ith].stakeTime);
            amountArr[i] = uint256(t_supply[ith].tamount);
            i = i+1;
        }
        return (timeArr,amountArr);
    }

    // 提取公共质押逻辑，消除代码重复
    function _stakeInternal(uint160 _amount, uint8 _stakeIndex, address parent) private {
        require(bStart, "ERC721: not Start");
        require(block.timestamp > startTime, "not Start!");
        require(_amount <= maxStakeAmount(), "<1000");
        require(_stakeIndex <= 2, "<=2");
        require(userStakeRecord[msg.sender].length < 200, "stake too long");
        
        address user = msg.sender;
        
        // 推荐关系处理（在流动性操作之前，避免浪费gas）
        // stakeWithInviter: 如果提供了推荐人且用户未绑定，则绑定推荐关系
        if (parent != address(0) && !isBindReferral(user)) {
            require(isBindReferral(parent), "Parent not bound");
            bindReferral(parent, user);
        }
        
        require(isBindReferral(user), "Must bind referral");

        swapAndAddLiquidity(_amount);

        mint(user, _amount, _stakeIndex);
    }
    
    function stake(uint160 _amount, uint8 _stakeIndex) external onlyEOA nonReentrant {
        _stakeInternal(_amount, _stakeIndex, address(0));
    }
    
    function stakeWithInviter(uint160 _amount, uint8 _stakeIndex, address parent) external onlyEOA nonReentrant {
        _stakeInternal(_amount, _stakeIndex, parent);
    }
    function getTokenAmountsOut(uint amountUsdt) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SFK);

        uint[] memory amountsOut = ROUTER.getAmountsOut(amountUsdt, path);
        price = amountsOut[1];
    }
    function getUsdtAmountsOut(uint amountToken) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(SFK);
        path[1] = address(USDT);
        
        uint[] memory amountsOut = ROUTER.getAmountsOut(amountToken, path);
        price = amountsOut[1];
    }

    function swapUsdtForTokens(uint256 uAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SFK);

        uint256 tokenAmount = getTokenAmountsOut(uAmount);

       ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uAmount,
            tokenAmount*mMinSwapRatioToken/100,  
            path,
            to,
            block.timestamp
        );
    }
            
    function swapAndAddLiquidity(uint160 _amount) private {
        require(address(sfExchange) != address(0), "SFExchange not set");
        
        USDT.transferFrom(msg.sender, address(this), _amount);

        // ============ 第一部分：USDT/SFK 流动性池 ============
        // 使用 50% 的 USDT 添加流动性到 USDT/SFK 池子
        uint256 halfAmount = _amount / 2;  // 500U (如果 _amount = 1000U)
        
        // 一半用来买 SFK（250U）
        uint256 usdtForSwap = halfAmount / 2;  // 250U
        
        // 另一半直接作为 USDT（250U）
        uint256 usdtForLiquidity = halfAmount / 2;  // 250U
        
        // 用 250U 兑换 SFK
        uint256 sfkAmount1 = swapUsdtForSFK(usdtForSwap, address(this));
        
        // 用 250U USDT + 买到的 SFK 组成 LP，添加到 USDT/SFK 交易对
        addLiquidityUSDTSFK(usdtForLiquidity, sfkAmount1, address(0xdead));

        // ============ 第二部分：SF/SFK 流动性池 ============
        // 先用剩余的 50% USDT 通过 sfExchange 换取 SF（无税）
        USDT.approve(address(sfExchange), halfAmount);
        uint256 actualSF = sfExchange.exchangeUSDTForSF(halfAmount);
        
        // 对半分：50% 的 SF 去 SFK 池子换成 SFK，50% 的 SF 保留
        uint256 sfForSwap = actualSF / 2;  // 50% 的 SF
        uint256 sfForLiquidity = actualSF / 2;  // 50% 的 SF 保留
        
        // 确保 SF 已授权给 ROUTER（用于兑换）
        SF.approve(address(ROUTER), sfForSwap);
        
        // 用 50% 的 SF 兑换 SFK
        uint256 sfkAmount = swapSFForSFK(sfForSwap, address(this));
        
        // 用 50% 的 SF + 换到的 SFK 组成 LP，添加到 SF/SFK 交易对
        addLiquiditySFSFK(sfForLiquidity, sfkAmount, address(0xdead));
    }
    
    function swapSFKForSF(uint256 sfkAmount, address to) private returns (uint256) {
        uint256 sfBefore = SF.balanceOf(to);
        
        address[] memory path = new address[](2);
        path[0] = address(SFK);
        path[1] = address(SF);
        
        SFK.approve(address(ROUTER), type(uint256).max);
        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sfkAmount,
            0,
            path,
            to,
            block.timestamp
        );
        uint256 sfAfter = SF.balanceOf(to);
        return sfAfter - sfBefore;
    }
    
    function swapSFKForUSDT(uint256 sfkAmount, address to) private returns (uint256) {
        uint256 usdtBefore = USDT.balanceOf(to);
        
        address[] memory path = new address[](2);
        path[0] = address(SFK);
        path[1] = address(USDT);
        
        SFK.approve(address(ROUTER), type(uint256).max);
        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sfkAmount,
            0,
            path,
            to,
            block.timestamp
        );
        uint256 usdtAfter = USDT.balanceOf(to);
        return usdtAfter - usdtBefore;
    }
    
    function swapSFForSFK(uint256 sfAmount, address to) private returns (uint256) {
        uint256 sfkBefore = SFK.balanceOf(to);
        
        address[] memory path = new address[](2);
        path[0] = address(SF);
        path[1] = address(SFK);
        
        SF.approve(address(ROUTER), type(uint256).max);
        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sfAmount,
            0,
            path,
            to,
            block.timestamp
        );
        uint256 sfkAfter = SFK.balanceOf(to);
        return sfkAfter - sfkBefore;
    }

    // 计算需要多少 SF（基于当前价格）
    function calculateRequiredSF(uint256 usdtAmount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SF);
        
        uint[] memory amounts = ROUTER.getAmountsOut(usdtAmount, path);
        return amounts[1];
    }

    function swapUsdtForSFK(uint256 uAmount, address to) private returns (uint256) {
        uint256 sfkBefore = SFK.balanceOf(to);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SFK);
        uint[] memory amountsOut = ROUTER.getAmountsOut(uAmount, path);
        USDT.approve(address(ROUTER), type(uint256).max);
        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uAmount,
            amountsOut[1] * mMinSwapRatioToken / 100,
            path,
            to,
            block.timestamp
        );
        return SFK.balanceOf(to) - sfkBefore;
    }

    function addLiquiditySFSFK(uint256 sfAmount, uint256 sfkAmount, address to) private {
        SF.approve(address(ROUTER), type(uint256).max);
        SFK.approve(address(ROUTER), type(uint256).max);
        ROUTER.addLiquidity(
            address(SF),
            address(SFK),
            sfAmount,
            sfkAmount,
            sfAmount * mMinSwapRatioToken / 100,
            sfkAmount * mMinSwapRatioToken / 100,
            to,
            block.timestamp
        );
    }

    function addLiquidityUSDTSFK(uint256 usdtAmount, uint256 sfkAmount, address to) private {
        USDT.approve(address(ROUTER), type(uint256).max);
        SFK.approve(address(ROUTER), type(uint256).max);
        ROUTER.addLiquidity(
            address(USDT),
            address(SFK),
            usdtAmount,
            sfkAmount,
            usdtAmount * mMinSwapRatioUsdt / 100,
            sfkAmount * mMinSwapRatioToken / 100,
            to,
            block.timestamp
        );
    }
    // =========================================

    function addLiquidityTokenToken(uint usdtAmount, uint tokenAmount,address to) private {
        ROUTER.addLiquidity(
            address(USDT),
            address(SF),
            usdtAmount,
            tokenAmount,
            usdtAmount*mMinSwapRatioUsdt/100,  
            tokenAmount*mMinSwapRatioToken/100, 
            to, 
            block.timestamp   
        );
    }

    function mint(address sender, uint160 _amount,uint8 _stakeIndex) private {
        require(isBindReferral(sender),"!!bind");
        RecordTT memory tsy;
        tsy.stakeTime = uint40(block.timestamp);
        //这里使用uint160  会不会类型溢出？
        tsy.tamount = uint160(totalSupply);
        t_supply.push(tsy);

        Record memory order;
        order.oriStakeTime = uint40(block.timestamp);
        order.stakeTime = uint40(block.timestamp);
        order.amount = _amount;
        order.status = false;
        order.stakeIndex = _stakeIndex;

        totalSupply += _amount;
        balances[sender] += _amount;
        
        // 更新当前分钟的质押量累加器（优化：O(1)复杂度）
        _updateMinuteStakeAmount(_amount);
        
        Record[] storage cord = userStakeRecord[sender];
        uint256 stake_index = cord.length;
        cord.push(order);

        address[] memory referrals = getReferrals(sender, maxD);
        for (uint8 i = 0; i < referrals.length; i++) {
            teamTotalInvestValue[referrals[i]] += _amount;
        }

        // 更新新分配逻辑的直推数据（通过 StakingReward 合约）
        if (address(stakingReward) != address(0)) {
            stakingReward.updateDirectReferralData(sender, _amount);
        }

        emit Transfer(address(0), sender, _amount);
        emit Staked(sender, _amount, block.timestamp, stake_index,stakeDays[_stakeIndex]);
    }


    function caclItem(Record storage user_record)private view returns (uint256 reward){
        uint256 stake_amount = user_record.amount;
        uint40 stake_time = user_record.stakeTime;
        uint40 endTime = uint40(block.timestamp);

        // 按照动态质押期限计算
        uint256 maxStakeDuration = stakeDays[user_record.stakeIndex];
        if(endTime > user_record.oriStakeTime + maxStakeDuration) {
            endTime = uint40(user_record.oriStakeTime + maxStakeDuration);
        }

        if(endTime<=stake_time) {
            reward = stake_amount;
            return reward;
        }

        uint40 stake_period = endTime - stake_time;

        // 按照动态质押期限计算
        uint40 maxPeriod = uint40(maxStakeDuration);
        stake_period = stake_period > maxPeriod ? maxPeriod : stake_period;
    
        if (stake_period == 0) {
            reward = stake_amount;
        } else {
            uint256 rate = rates[user_record.stakeIndex];
            uint256 factor = powu(rate, stake_period);
            reward = (stake_amount * factor) / 1e18;
        }
    }

    function powu(uint256 base, uint256 exp) internal pure returns (uint256 result) {
        result = 1e18;
        while (exp > 0) {
            if (exp & 1 != 0) {
                result = (result * base) / 1e18;
            }
            base = (base * base) / 1e18;
            exp >>= 1;
        }
    }

    struct Vars {
        uint256 reward;          // 总收益（SFK 数量，本金+收益）
        uint256 stake;           // 本金（SFK 数量）
        uint256 sfkBefore;       // 交换前的 SFK 余额
        uint256 usdtBefore;      // 交换前的 USDT 余额
        uint256 sfBefore;        // 交换前的 SF 余额
        uint256 totalUsdtValue;  // 总 USDT 价值（基于当前价格）
        uint256 halfUsdtValue;   // 一半的 USDT 价值
        uint256 usdtFromPool1;   // 从 USDT/SFK 池获得的 USDT
        uint256 sfFromPool2;     // 从 SF/SFK 池获得的 SF
        uint256 usdtFromExchange; // 通过 sfExchange 获得的 USDT
        uint256 totalUsdtForUser; // 用户总共获得的 USDT
        uint256 actualSFK1Used;   // USDT池实际使用的 SFK（用于 recycle）
        uint256 actualSFK2Used;   // SF池实际使用的 SFK（用于 recycle）
    }

    function unstake(uint256 index) external onlyEOA nonReentrant returns (uint256) {
        Vars memory v;
        (v.reward, v.stake) = burn(index);

        // 记录交换前的余额
        v.sfkBefore = SFK.balanceOf(address(this));
        v.usdtBefore = USDT.balanceOf(address(this));
        v.sfBefore = SF.balanceOf(address(this));

        // 计算总 USDT 价值（v.reward 是 SFK 数量）
        v.totalUsdtValue = getUsdtAmountsOut(v.reward);
        v.halfUsdtValue = v.totalUsdtValue / 2;  // 50% 分配

        // 第一部分：从 USDT/SFK 池获取 USDT
        address[] memory pathUsdt = new address[](2);
        pathUsdt[0] = address(SFK);
        pathUsdt[1] = address(USDT);
        uint256[] memory amountsInUsdt = ROUTER.getAmountsIn(v.halfUsdtValue, pathUsdt);
        uint256 requiredSFK1 = amountsInUsdt[0];
        
        // 检查合约是否有足够的 SFK
        require(v.sfkBefore >= requiredSFK1, "Insufficient SFK balance for USDT pool");

        // 记录 swap 前的 SFK 余额
        uint256 sfkBeforeSwap1 = SFK.balanceOf(address(this));
        
        // 从 USDT/SFK 池 swap SFK → USDT
        v.usdtFromPool1 = swapSFKForUSDT(requiredSFK1, address(this));

        // 记录实际使用的 SFK 数量
        v.actualSFK1Used = sfkBeforeSwap1 - SFK.balanceOf(address(this));

        // 第二部分：从 SF/SFK 池获取 SF，通过 sfExchange 换成 USDT
        // 通过 SFExchange 计算需要多少 SF 才能换到 v.halfUsdtValue 的 USDT
        uint256 requiredSF = sfExchange.calculateSFAmount(v.halfUsdtValue);

        // 多使用 1% 的 SFK 去换取 SF
        uint256 requiredSFWithBuffer = requiredSF * 101 / 100;
        
        // 计算需要多少 SFK 才能从 SF/SFK 池换到 requiredSF 数量的 SF
        address[] memory pathSfkToSf = new address[](2);
        pathSfkToSf[0] = address(SFK);
        pathSfkToSf[1] = address(SF);
        uint256[] memory amountsInSfkToSf = ROUTER.getAmountsIn(requiredSFWithBuffer, pathSfkToSf);
        uint256 requiredSFK2 = amountsInSfkToSf[0];
        
        // 检查合约是否有足够的 SFK
        require(v.sfkBefore >= requiredSFK1 + requiredSFK2, "Insufficient SFK balance for SF pool");
        
        // 从 SF/SFK 池 swap SFK → SF
        v.sfFromPool2 = swapSFKForSF(requiredSFK2, address(this));
        v.actualSFK2Used = requiredSFK2;

        // 通过 sfExchange 将 SF 换成 USDT
        SF.approve(address(sfExchange), type(uint256).max);
        if (v.sfFromPool2 >= requiredSF) {
            v.usdtFromExchange = sfExchange.exchangeSFForUSDT(v.sfFromPool2);
            // 将多余的 SF 转给 SFExchange 作为储备
            uint256 sfRemaining = v.sfFromPool2 - requiredSF;
            if (sfRemaining > 0) {
                SF.transfer(address(sfExchange), sfRemaining);
            }
        } else {
            // 如果得到的 SF 少于需要的，全部使用
            v.usdtFromExchange = sfExchange.exchangeSFForUSDT(v.sfFromPool2);
        }

        // 计算用户应得的 USDT
        v.totalUsdtForUser = v.usdtFromPool1 + v.usdtFromExchange;

        // CEI模式：先更新状态
        address[] memory refs = getReferrals(msg.sender, maxD);
        for (uint256 i = 0; i < refs.length; ++i) {
            teamTotalInvestValue[refs[i]] -= v.stake;
        }

        // 解压发出事件
        if(address(stakingReward) != address(0)){
            stakingReward.emitUnstakePerformanceUpdate(msg.sender, v.stake);
        }
        
        
        // 计算收益部分（用于奖励分配）
        uint256 profitReward = 0;
        if (v.reward > v.stake) {
            profitReward = v.reward - v.stake;
        }
        
        // 调用奖励分配逻辑（通过 StakingReward 合约）
        if (address(stakingReward) != address(0) && profitReward > 0) {
            // 将收益转换为 USDT 价值
            uint256 profitUsdt = getUsdtAmountsOut(profitReward);
            if (profitUsdt > 0) {
                stakingReward.newDistributionLogic(msg.sender, profitUsdt);
            }
        }

        // 执行外部调用
        USDT.transfer(msg.sender, v.totalUsdtForUser);

        // 回收使用的 SFK 回到 Staking 合约
        SFK.recycleUSDT(v.actualSFK1Used);
        SFK.recycleSF(v.actualSFK2Used);

        // 触发事件：通知链下处理
        emit UnstakeSFToWhitelist(
            msg.sender, 
            v.sfFromPool2,           // 发送到白名单的 SF 数量
            v.halfUsdtValue,         // 期望的 USDT 价值
            v.usdtFromExchange,      // 实际通过 exchange 得到的 USDT
            uint40(block.timestamp)
        );
        
        emit Unstake(msg.sender, v.reward, uint40(block.timestamp), index);
        
        return v.reward;
    }
    
    function burn(uint256 index)private returns (uint256 reward, uint256 amount){
        address sender = msg.sender;
        Record[] storage cord = userStakeRecord[sender];
        Record storage user_record = cord[index];

        require(block.timestamp >= stakeDays[user_record.stakeIndex]+user_record.oriStakeTime, "The time is not right");

        require(!user_record.status, "alw");

        amount = user_record.amount;
        totalSupply -= amount;
        balances[sender] -= amount;
        emit Transfer(sender, address(0), amount);

        reward = caclItem(user_record);
        user_record.status = true;

        uint256 lastIndex = cord.length - 1;
        if (index != lastIndex) {
            cord[index] = cord[lastIndex]; 
        }
        cord.pop(); 
        userIndex[sender] = userIndex[sender] + 1;
    }
    function calReward(uint256 index)private returns (uint256 reward, uint256 amount){
        address sender = msg.sender;
        Record[] storage cord = userStakeRecord[sender];
        Record storage user_record = cord[index];

        uint256 stakeTime = user_record.stakeTime;
        require(block.timestamp >= stakeTime+timeStep, "need wait");
        require(!user_record.status, "alw");

        amount = user_record.amount;
        reward = caclItem(user_record);
        user_record.stakeTime = uint40(block.timestamp);

        userIndex[sender] = userIndex[sender] + 1;
        require(reward > amount, "none reward");
        emit RewardOnly(msg.sender, reward - amount, uint40(block.timestamp), index);
    }

    function sync() external {
        uint256 w_bal = IERC20(USDT).balanceOf(address(this));
        address pair = SF.uniswapV2Pair();
        IERC20(USDT).transfer(pair, w_bal);
        IUniswapV2Pair(pair).sync();
    }
    function setMinSwapRatio(uint256 minSwapRatioUsdt,uint256 minSwapRatioToken) external onlyOwner{
        mMinSwapRatioUsdt=minSwapRatioUsdt;
        mMinSwapRatioToken=minSwapRatioToken;
    }

    function setTeamVirtuallyInvestValue(address _user, uint256 _value)external onlyOwner{
        teamVirtuallyInvestValue[_user] = _value;
    }

    function emergencyWithdrawSF(uint256 _amount)external onlyOwner{
        SF.transfer(fundAddress, _amount);
    }

    function withdraw(uint256 amount) external onlyOwner{
        (bool success, ) = payable(fundAddress).call{value: amount}("");
        require(success, "Low-level call failed");
    }

    function withdrawToken(address tokenAddr,uint256 amount) external onlyOwner{ 
        IERC20 token = IERC20(tokenAddr);
        token.transfer(fundAddress, amount);
    }
    function setStart(bool tbstart,uint256 startT) external onlyOwner{
        bStart = tbstart;
        startTime = startT;
    }
    
    // 查询函数（委托给 StakingReward 合约）
    function getDirectReferralCount(address user) public view returns (uint256) {
        if (address(stakingReward) != address(0)) {
            return stakingReward.getDirectReferralCount(user);
        }
        return 0;
    }
    
    function getTeamLevel(address user) public view returns (uint256) {
        if (address(stakingReward) != address(0)) {
            return stakingReward.getTeamLevel(user);
        }
        return 0;
    }
    
    function getNewDistributionInfo(address user) external view returns (
        uint256 referralProfit,
        uint256 teamProfit,
        uint256 teamLevelValue,
        uint256 directCount,
        bool canClaimReward
    ) {
        if (address(stakingReward) != address(0)) {
            return stakingReward.getNewDistributionInfo(user);
        }
        return (0, 0, 0, 0, false);
    }
    
    function getDepartmentStats(address user) external view returns (
        uint256 count3,
        uint256 count4,
        uint256 count5,
        uint256 dept1Level,
        uint256 dept2Level,
        uint256 teamKpi
    ) {
        if (address(stakingReward) != address(0)) {
            return stakingReward.getDepartmentStats(user);
        }
        return (0, 0, 0, 0, 0, 0);
    }
}
