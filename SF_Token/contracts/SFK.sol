// SPDX-License-Identifier: AGPL-3.0-only AND MIT AND UNLICENSED
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


// File @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol@v1.0.1

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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
address constant _ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PancakeSwap Router
address constant FUND_ADDRESS = 0xf3A51876c0Fb4FA7F99A62E3D6CF7d0574Aeb60d; // Fund Address (测试用 Owner 地址)
address constant NFT_ADDRESS = 0x2B1511Dc09B718f74eE8A6953a4C3eC49949f705; // NFT Address


// File contracts/abstract/dex/BaseDEX.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.4;




address constant PinkLock02 = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

contract Distributor {
    constructor() {
        IERC20(_USDT).approve(msg.sender, type(uint256).max);
        IERC20(_SF).approve(msg.sender, type(uint256).max);
    }
}

abstract contract BaseDEX {
    IUniswapV2Router02 constant uniswapV2Router = IUniswapV2Router02(_ROUTER);
    address public immutable uniswapV2PairUSDT;
    address public immutable uniswapV2PairSF;
    Distributor public immutable distributor;

    constructor() {
        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), _USDT);
        uniswapV2PairSF = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), _SF);
        distributor = new Distributor();
    }
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


// File contracts/abstract/ExcludedFromFeeList.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity >=0.8.17;

abstract contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts) public onlyOwner {
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len;) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
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


// File contracts/abstract/FirstLaunch.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract FirstLaunch {
    uint40 public launchedAtTimestamp;

    function launch() internal {
        require(launchedAtTimestamp == 0, "Already launched");
        launchedAtTimestamp = uint40(block.timestamp);
    }
}


// File contracts/interface/IReferral.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.13;

interface IReferral{
    
    event BindReferral(address indexed user,address parent);
    
    function getReferral(address _address)external view returns(address);

    function isBindReferral(address _address) external view returns(bool);

    function getReferralCount(address _address) external view returns(uint256);

    function bindReferral(address _referral,address _user) external;

    function getReferrals(address _address,uint256 _num) external view returns(address[] memory);

    function getRootAddress()external view returns(address);
}


// File contracts/interface/IStaking.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IStaking {
    function balances(address) external view returns (uint256);
    function isPreacher(address) external  view returns(bool);
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


// File contracts/lib/Helper.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.20;

library Helper {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        uint256 amountInWithFee = amountIn * 9975;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        uint256 numerator = reserveIn * amountOut * 10000;
        uint256 denominator = (reserveOut - amountOut) * 9975;
        amountIn = (numerator / denominator) + 1;
    }
}


// File contracts/SFK.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;











abstract contract ERC20 is Owned, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;
    uint256 private immutable _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    ITWAPOracle public immutable twapOracle;

    constructor(
        string memory name0,
        string memory symbol0,
        uint8 decimals0,
        uint256 totalSupply0,
        address twapOracleAddress
    ) Owned(msg.sender) {
        _name = name0;
        _symbol = symbol0;
        _decimals = decimals0;
        _totalSupply = totalSupply0;
        _balances[FUND_ADDRESS] = _totalSupply;

        emit Transfer(address(0), FUND_ADDRESS, _totalSupply);

        twapOracle = ITWAPOracle(twapOracleAddress);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {
        require(_from != address(0), "transfer from the zero address");
        require(_balances[_from] >= _amount, "ERC20: transfer amount exceeds balance");
        _balances[_from] = _balances[_from] - _amount;
        _balances[_to] = _balances[_to] + _amount;
        emit Transfer(_from, _to, _amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      function getDailyClosePrice() external view returns (uint256) {
        return twapOracle.getDailyClosePrice();
    }

    function getCurrentPrice() external view returns (uint256) {
        return twapOracle.getCurrentPrice();
    }
    function getPriceChangeBps() external view returns (int256) {
        return twapOracle.getPriceChangeBps();
    }
}

contract SFK is ExcludedFromFeeList, BaseDEX, FirstLaunch, ERC20 {
    bool public presale;
    uint40 public coldTime = 1 minutes;

    // uint256 public amountLPFeeUSDT;  // USDT池的LP费用
    // uint256 public amountLPFeeSF;    // SF池的LP费用
    // uint256 public amountNodeFee;    // 节点费用（统一换USDT）
    // uint256 public amountTechFee;    // 技术费用（统一换USDT）

    // 记录扣税的SFK的数量
    uint256 public totalAmountLPFeeUSDT;
    uint256 public totalAmountNodeFee;
    uint256 public totalAmountTechFee;

    uint256 public totalAmountLPFeeSF;

    // 不需要换成SF，直接SFK换成USDT就可以了，统一全部使用SFK扣税，然后转成USDT
    // uint256 public totalAmountNodeFeeSF;
    // uint256 public totalAmountTechFeeSF;

    //盈利税地址（用于回购销毁）
    address public profitAddress = 0xFDbC769D3C7d7726e78820Dc7ea0Efd17dccCCC6;
    // 技术运营地址（卖出时1%）
    address public techAddress = 0x8D7418dD38423a07AE641c7b4CBf41dD195D7c7D;
    // 节点分红地址
    address public NFTNodeAddress = 0x86EA2cA99A9b6ea3FBbc148a25e6076e82Ab9341;
    
    // 如果2100万 就累积200个？
    uint256 public swapAtAmount = 20 ether;

    mapping(address => bool) public _rewardList;

    mapping(address => uint256) public tOwnedU;
    mapping(address => uint40) public lastBuyTime;
    address public STAKING;
    // 是否已经不需要对上级奖励了
    // address immutable REFERRAL;
    
    uint256 MAX_BURN_AMOUNT = 8900000 ether; // 890万枚销毁上限

    bool public inSwapAndLiquify;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    struct POOLUStatus {
        uint112 balance;
        uint40 timestamp;
    }

    // 没有用处是否考虑删除掉
    POOLUStatus public poolStatusUSDT; // USDT 池状态
    POOLUStatus public poolStatusSF;   // SF 池状态

    constructor(address twapOracleAddress) ERC20("SFK", "SFK", 18, 11000000 ether, twapOracleAddress) {
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        IERC20(_USDT).approve(address(uniswapV2Router), type(uint256).max);
        IERC20(_SF).approve(address(uniswapV2Router), type(uint256).max);

        excludeFromFee(msg.sender);
        excludeFromFee(address(this));
        excludeFromFee(STAKING);
        excludeFromFee(FUND_ADDRESS);
        excludeFromFee(profitAddress);
        excludeFromFee(techAddress);
    }

    function updatePoolReserveUSDT() public {
        if (block.timestamp >= poolStatusUSDT.timestamp + 1 hours) {
            poolStatusUSDT.timestamp = uint40(block.timestamp);
            (uint112 reserveU, ) = getMyReserves(uniswapV2PairUSDT);
            poolStatusUSDT.balance = reserveU;
        }
    }

    function updatePoolReserveUSDT(uint112 reserveU) private {   
        if (block.timestamp >= poolStatusUSDT.timestamp + 1 hours) {
            poolStatusUSDT.timestamp = uint40(block.timestamp);
            poolStatusUSDT.balance = reserveU;
        }
    }

    function getReserveUSDT() external view returns (uint112) {
        return poolStatusUSDT.balance;
    }

    function updatePoolReserveSF() public {
        if (block.timestamp >= poolStatusSF.timestamp + 1 hours) {
            poolStatusSF.timestamp = uint40(block.timestamp);
            (uint112 reserveSF, ) = getMyReserves(uniswapV2PairSF);
            poolStatusSF.balance = reserveSF;
        }
    }

    function updatePoolReserveSF(uint112 reserveSF) private {   
        if (block.timestamp >= poolStatusSF.timestamp + 1 hours) {
            poolStatusSF.timestamp = uint40(block.timestamp);
            poolStatusSF.balance = reserveSF;
        }
    }

    function getReserveSF() external view returns (uint112) {
        return poolStatusSF.balance;
    } 

    // function _isPair(address addr) internal view returns (bool) {
    //     if (addr == address(0) || !Helper.isContract(addr)) {
    //         return false;
    //     }
    //     // 尝试调用 getReserves() 来判断是否是 Pair
    //     // 如果调用成功，说明是 Pair
    //     try IUniswapV2Pair(addr).getReserves() returns (uint112, uint112, uint32) {
    //         return true;
    //     } catch {
    //         return false;
    //     }
    // }

    function getMyReserves(
        address pair
    ) internal view returns (uint112 uReserve, uint112 tokenReserve) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair)
            .getReserves();
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if (token0 == address(this)) {
            return (reserve1, reserve0);
        } else if (token1 == address(this)) {
            return (reserve0, reserve1);
        } else {
            revert("Current contract is not in this pair");
        }
    }

    // 使用USDT计算出SFK
    function getTokenAmountsOut(
        uint amountUsdt
    ) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(_USDT);
        path[1] = address(this);

        uint[] memory amountsOut = uniswapV2Router.getAmountsOut(
            amountUsdt,
            path
        );
        price = amountsOut[1];
    }

    // 使用SFK计算出USDT
    function getUsdtAmountsOut(
        uint amountToken
    ) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_USDT);

        uint[] memory amountsOut = uniswapV2Router.getAmountsOut(
            amountToken,
            path
        );
        price = amountsOut[1];
    }

    // 使用SFK计算出SF
    function getSfAmountsOut(uint amountToken) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_SF);
        
        uint[] memory amountsOut = uniswapV2Router.getAmountsOut(amountToken, path);
        price = amountsOut[1];
    }

    // 计算 SF 的 USDT 价值
    function getUsdtValueOfSf(uint256 sfAmount) public view returns (uint256) {
        // 使用 SF/USDT 交易对
        address[] memory path = new address[](2);
        path[0] = address(_SF);
        path[1] = address(_USDT);
        
        uint[] memory amountsOut = uniswapV2Router.getAmountsOut(sfAmount, path);
        return amountsOut[1];
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        
        require(!isReward(sender), "sender in reward list");
        
        if (
            inSwapAndLiquify ||
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient]
        ) {
            super._transfer(sender, recipient, amount);
            return;
        }
        
        // 如果是USDT交易对
        if (sender == uniswapV2PairUSDT || recipient == uniswapV2PairUSDT) {
            usdt_transfer(sender, recipient, amount);
            return;
        } 

        // 如果是SF交易对
        if (sender == uniswapV2PairSF || recipient == uniswapV2PairSF) {
            sf_transfer(sender, recipient, amount);
            return;
        }
        super._transfer(sender, recipient, amount);
    }

    function usdt_transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        // 接收者如果是合约，必须是 uniswapV2Pair
        require(
            !Helper.isContract(recipient) || uniswapV2PairUSDT == recipient,
            "contract"
        );
        if (uniswapV2PairUSDT == sender) {
            // buy
            require(presale, "pre");
            (uint112 reserveU, uint112 reserveThis) = getMyReserves(
                uniswapV2PairUSDT
            );
            require(amount <= reserveThis / 10, "max buy cap");
            updatePoolReserveUSDT(reserveU);
            uint256 amountUBuy = getUsdtAmountsOut(amount);
            tOwnedU[recipient] = tOwnedU[recipient] + amountUBuy;
            lastBuyTime[recipient] = uint40(block.timestamp);

            // 1% 销毁费用
            // 代币分配：
            // - 发行总量：1100万枚
            // - LP底池：700万枚（一次性进入底池，通过交易逐步销毁）
            // - 交互合约：100万枚（永久恒定，不参与销毁）
            // - 早期空投：300万枚（通过交易逐步销毁）
            // - 目标：持续销毁至剩余210万枚
            // - 需要销毁：1000万 - 210万 = 790万
            uint256 burnFee;
            uint256 burnAmount = balanceOf(address(0xdead));
            if (burnAmount < MAX_BURN_AMOUNT) {
                burnFee = (amount * 10) / 1000; // 1% 销毁费率
                // 确保不超过销毁上限
                burnFee = MAX_BURN_AMOUNT - burnAmount > burnFee
                    ? burnFee
                    : MAX_BURN_AMOUNT - burnAmount;
                super._transfer(sender, address(0xdead), burnFee);
            }
            // 达到销毁上限后，不再收取销毁费用
            
            // 1% LP费用
            uint256 buyLPFee = (amount * 10) / 1000;
            totalAmountLPFeeUSDT += buyLPFee;
            super._transfer(sender, address(this), buyLPFee);
            
            // 1% 节点分红
            uint256 buyNodeFee = (amount * 10) / 1000;
            totalAmountNodeFee += buyNodeFee;
            super._transfer(sender, address(this), buyNodeFee);

            uint256 totalFees = burnFee + buyLPFee + buyNodeFee;
            
            // 用户实际收到：amount - burnFee - lpFee - nodeFee
            super._transfer(sender, recipient, amount - totalFees);
            
        } else if (uniswapV2PairUSDT == recipient) {
            //sell
            require(presale, "pre");
            // 前1分钟内不允许卖出
            require(block.timestamp >= lastBuyTime[sender] + coldTime, "cold");
            (uint112 reserveU, uint112 reserveThis) = getMyReserves(
                uniswapV2PairUSDT
            );

            require(amount <= reserveThis / 10, "max sell cap"); // 10% 最大卖出量

            // 卖出税：基础3%（1%回流LP、1%节点分红、1%技术运营）
            // 前15分钟内额外增加5%（总共8%）
            uint256 sellExtraFee = 0; // 前15分钟的额外5%
            if (launchedAtTimestamp > 0 && 
                block.timestamp - launchedAtTimestamp <= 15 minutes) {
                sellExtraFee = (amount * 50) / 1000; // 额外5%
            }
            
            uint256 sellLPFee = (amount * 10) / 1000; // 1% LP费用
            uint256 sellNodeFee = (amount * 10) / 1000; // 1% 节点分红
            
            // 基础技术运营费用：1%
            uint256 sellTechFee = (amount * 10) / 1000;
            
            // 动态技术运营费用：如果跌幅超过13%，每增加1%跌幅，技术运营费用增加1%，最高到30%（最多增加17%）
            int256 priceChangeBps = twapOracle.getPriceChangeBps();
            uint256 dynamicTechFee = 0;
            // 只有下跌（负数）且跌幅超过13%（1300基点）才增加技术运营费用
            if (priceChangeBps < 0) {
                uint256 absPriceChange = uint256(-priceChangeBps); // 转换为正数
                if (absPriceChange >= 1300) {
                    // 限制最高跌幅为30%（3000基点）
                    uint256 cappedPriceChange = absPriceChange > 3000 ? 3000 : absPriceChange;
                    // 计算超过13%的部分（以基点为单位）
                    uint256 excessBps = cappedPriceChange - 1300;
                    // 每1基点跌幅增加1基点技术运营费用（例如：跌幅20% = 2000基点，excessBps = 700基点，即7%）
                    dynamicTechFee = (amount * excessBps) / 10000;
                }
            }
            
            // 总技术运营费用 = 基础1% + 动态费用
            sellTechFee = sellTechFee + dynamicTechFee;

            uint256 baseFee = sellLPFee + sellNodeFee + sellTechFee + sellExtraFee;
            
            // 计算卖出得到的 USDT（扣除卖出税后，包括前15分钟的额外5%）
            uint256 amountUOut = getUsdtAmountsOut(amount - baseFee);
            updatePoolReserveUSDT(reserveU);

            // 盈利税：10%（不定期回购销毁代币，地址公示）
            uint256 profitFee = 0;
            if (tOwnedU[sender] >= amountUOut) {
                // 没有盈利，只扣除成本
                unchecked {
                    tOwnedU[sender] = tOwnedU[sender] - amountUOut;
                }
            } else if (tOwnedU[sender] > 0 && tOwnedU[sender] < amountUOut) {
                // 有盈利，收取盈利的 10%（换算成代币后的10%,用于回购销毁）
                uint256 profitU = amountUOut - tOwnedU[sender];
                uint256 profitThis = getTokenAmountsOut(profitU);
                profitFee = (profitThis * 100) / 1000; // 盈利税 10%
                tOwnedU[sender] = 0;
            } else {
                // 无买入记录，收取卖出金额的 10%（用于回购销毁）
                profitFee = (amount * 100) / 1000;
                tOwnedU[sender] = 0;
            }
            
            // 计算所有费用总和
            uint256 totalFee = baseFee + profitFee;
            
            // 一次性将所有费用转账到合约
            super._transfer(sender, address(this), totalFee);
            // 累积卖出税费用（需要在 swapProfit 之前更新，因为 swapProfit 会使用这些值计算余额）
            totalAmountLPFeeUSDT += sellLPFee;
            totalAmountNodeFee += sellNodeFee;
            totalAmountTechFee += sellTechFee;
            
            // 处理盈利税（用于回购销毁，地址：profitAddress）
            if (profitFee > 0) {
                if (shouldSwapProfit(profitFee)) {
                    swapProfit(profitFee, sender);
                }
            }
            
            // 前15分钟的额外5%费用（用于回购销毁）
            if (sellExtraFee > 0) {
                if (shouldSwapProfit(sellExtraFee)) {
                    swapProfit(sellExtraFee, sender);
                }
            }

            // 检查是否需要处理累积的费用
            if (shouldSwapTokenForFund(totalAmountLPFeeUSDT + totalAmountNodeFee + totalAmountTechFee)) {
                swapTokenForFund();
            }

            // 用户实际收到：amount - 所有费用
            uint256 finalAmount = amount - totalFee;
            super._transfer(sender, recipient, finalAmount);
    
        } else {
            // 普通转账，在外部处理
        }
    }

    function sf_transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        // 接收者如果是合约，必须是 uniswapV2PairSF
        require(
            !Helper.isContract(recipient) || uniswapV2PairSF == recipient,
            "contract"
        );
        // 发送者如果是合约 必须是pair ???? 这个是不是会阻止聚合器？
        // require(
        //     !Helper.isContract(sender) || uniswapV2PairSF == sender,
        //     "contract"
        // );

        if (uniswapV2PairSF == sender) {
            // buy
            require(presale, "pre");
            (uint112 reserveSF, uint112 reserveThis) = getMyReserves(
                uniswapV2PairSF
            );
            require(amount <= reserveThis / 10, "max buy cap");
            updatePoolReserveSF(reserveSF);
            // 统一使用USDT池价格计算本金
            uint256 amountUBuy = getUsdtAmountsOut(amount);
            tOwnedU[recipient] = tOwnedU[recipient] + amountUBuy;
            lastBuyTime[recipient] = uint40(block.timestamp);

            // 1% 销毁费用
            // 代币分配：
            // - 发行总量：1100万枚
            // - LP底池：900万枚（一次性进入底池，通过交易逐步销毁）
            // - 交互合约：100万枚（永久恒定，不参与销毁）
            // - 早期空投：100万枚（通过交易逐步销毁）
            // - 目标：持续销毁至剩余210万枚
            // - 需要销毁：1000万 - 210万 = 790万
            uint256 burnFee;
            uint256 burnAmount = balanceOf(address(0xdead));
            if (burnAmount < MAX_BURN_AMOUNT) {
                burnFee = (amount * 10) / 1000; // 1% 销毁费率
                // 确保不超过销毁上限
                burnFee = MAX_BURN_AMOUNT - burnAmount > burnFee
                    ? burnFee
                    : MAX_BURN_AMOUNT - burnAmount;
                super._transfer(sender, address(0xdead), burnFee);
            }
            // 达到销毁上限后，不再收取销毁费用
            
            // 1% LP费用
            uint256 LPFee = (amount * 10) / 1000;
            totalAmountLPFeeSF += LPFee;
            super._transfer(sender, address(this), LPFee);
            
            // 1% 节点分红
            uint256 nodeFee = (amount * 10) / 1000;
            totalAmountNodeFee += nodeFee;
            super._transfer(sender, address(this), nodeFee);

            uint256 totalFees = burnFee + LPFee + nodeFee;

            // 用户实际收到：amount - burnFee - LPFee - nodeFee
            super._transfer(sender, recipient, amount - totalFees);

        } else if (uniswapV2PairSF == recipient) {
            //sell
            require(presale, "pre");
            
            // 前1分钟内不允许卖出
            require(block.timestamp >= lastBuyTime[sender] + coldTime, "cold");
            (uint112 reserveSF, uint112 reserveThis) = getMyReserves(
                uniswapV2PairSF
            );

            require(amount <= reserveThis / 10, "max sell cap");
            
            // 卖出税：基础3%（1%回流LP、1%节点分红、1%技术运营）
            // 前15分钟内额外增加5%（总共8%）
            uint256 sellExtraFee = 0; // 前15分钟的额外5%
            if (launchedAtTimestamp > 0 && 
                block.timestamp - launchedAtTimestamp <= 15 minutes) {
                sellExtraFee = (amount * 50) / 1000; // 额外5%
            }
            
            uint256 sellLPFee = (amount * 10) / 1000; // 1% LP费用
            uint256 sellNodeFee = (amount * 10) / 1000; // 1% 节点分红
            
            // 基础技术运营费用：1%
            uint256 sellTechFee = (amount * 10) / 1000;
            
            // 动态技术运营费用：如果跌幅超过13%，每增加1%跌幅，技术运营费用增加1%，最高到30%（最多增加17%）
            int256 priceChangeBps = twapOracle.getPriceChangeBps();
            uint256 dynamicTechFee = 0;
            // 只有下跌（负数）且跌幅超过13%（1300基点）才增加技术运营费用
            if (priceChangeBps < 0) {
                // 防止溢出
                require(priceChangeBps > type(int256).min, "Price change overflow");
                uint256 absPriceChange = uint256(-priceChangeBps); // 转换为正数
                if (absPriceChange >= 1300) {
                    // 限制最高跌幅为30%（3000基点）
                    uint256 cappedPriceChange = absPriceChange > 3000 ? 3000 : absPriceChange;
                    // 计算超过13%的部分（以基点为单位）
                    uint256 excessBps = cappedPriceChange - 1300;
                    // 每1基点跌幅增加1基点技术运营费用（例如：跌幅20% = 2000基点，excessBps = 700基点，即7%）
                    dynamicTechFee = (amount * excessBps) / 10000;
                }
            }
            
            // 总技术运营费用 = 基础1% + 动态费用
            sellTechFee = sellTechFee + dynamicTechFee;

            uint256 baseFee = sellLPFee + sellNodeFee + sellTechFee + sellExtraFee;

            // 统一使用USDT池价格计算卖出收益
            uint256 amountUOut = getUsdtAmountsOut(amount - baseFee);
            
            updatePoolReserveSF(reserveSF);

            // 盈利税：10%（不定期回购销毁代币，地址公示）
            uint256 profitFee = 0;
            
            if (tOwnedU[sender] >= amountUOut) {
                // 没有盈利，只扣除成本
                unchecked {
                    tOwnedU[sender] = tOwnedU[sender] - amountUOut;
                }
            } else if (tOwnedU[sender] > 0 && tOwnedU[sender] < amountUOut) {
                // 有盈利，收取盈利的 10%（用于回购销毁）
                uint256 profitU = amountUOut - tOwnedU[sender];
                uint256 profitThis = getTokenAmountsOut(profitU);
                profitFee = (profitThis * 100) / 1000; // 盈利税 10%
                tOwnedU[sender] = 0;
            } else {
                // 无买入记录，收取卖出金额的 10%（用于回购销毁）
                profitFee = (amount * 100) / 1000;
                tOwnedU[sender] = 0;
            }
            
            // 计算所有费用总和
            uint256 totalFee = baseFee + profitFee;
       
            // 累积卖出税费用（需要在 swapProfit 之前更新，因为 swapProfit 会使用这些值计算余额）
            totalAmountLPFeeSF += sellLPFee;
            totalAmountNodeFee += sellNodeFee;
            totalAmountTechFee += sellTechFee;

            // 一次性将所有费用转账到合约
            super._transfer(sender, address(this), totalFee);

            // 处理盈利税（用于回购销毁，地址：profitAddress）
            if (profitFee > 0) {
                if (shouldSwapProfit(profitFee)) {
                    swapProfit(profitFee, sender);
                }
            }
            
            // 前15分钟的额外5%费用（用于回购销毁）
            if (sellExtraFee > 0) {
                if (shouldSwapProfit(sellExtraFee)) {
                    swapProfit(sellExtraFee, sender);
                }
            }
            
            // 检查是否需要处理累积的费用
            if (shouldSwapTokenForFund(totalAmountLPFeeSF + totalAmountNodeFee + totalAmountTechFee)) {
                swapTokenForFund();
            }
            
            // 用户实际收到：amount - 所有费用
            uint256 finalAmount = amount - totalFee;
            super._transfer(sender, recipient, finalAmount);
        } else {
            // 普通转账，在外部处理
        }
    }


    function shouldSwapTokenForFund(
        uint256 amount
    ) internal view returns (bool) {
        return amount >= swapAtAmount && !inSwapAndLiquify;
    }

    function swapTokenForFund() internal lockTheSwap {
        // 1% LP费用：回流到流动性池
        // USDT池的LP费用：回流到 USDT/SFK 池
        if (totalAmountLPFeeUSDT > 0) {
            swapAndLiquifyUSDT(totalAmountLPFeeUSDT);
            totalAmountLPFeeUSDT = 0;
        }

        // SF池的LP费用：回流到 SF/SFK 池
        if (totalAmountLPFeeSF > 0) {
            swapAndLiquifySF(totalAmountLPFeeSF);
            totalAmountLPFeeSF = 0;
        }
        
        // 1% 节点分红
        if (totalAmountNodeFee > 0) {
            swapTokenForUsdt(totalAmountNodeFee, NFTNodeAddress);
            totalAmountNodeFee = 0;
        }
        
        // 1% 技术运营：换成 USDT 后转给技术运营地址
        if (totalAmountTechFee > 0) {
            swapTokenForUsdt(totalAmountTechFee, techAddress);
            totalAmountTechFee = 0;
        }
    }

    function shouldSwapProfit(uint256 amount) internal view returns (bool) {
        return amount >= 1 gwei && !inSwapAndLiquify;
    }

    function swapProfit(
        uint256 tokenAmount,
        address _user
    ) internal lockTheSwap {
        uint256 balance = 0;
        uint256 contractBalance = balanceOf(address(this));
        uint256 reservedAmount = totalAmountLPFeeUSDT + totalAmountLPFeeSF + totalAmountNodeFee + totalAmountTechFee;
        
        if (contractBalance > reservedAmount) {
            balance = contractBalance - reservedAmount;
        }
        
        if (balance == 0) {
            return;
        }
        
        uint256 t2 = tokenAmount;
        uint256 amountIn = t2 >= balance ? balance : t2;
        
        unchecked {
            uint256 amount0 = IERC20(_USDT).balanceOf(address(distributor));
            
            swapTokenForUsdt(amountIn, address(distributor));
            
            uint256 amount = IERC20(_USDT).balanceOf(address(distributor)) - amount0;
            
            // 盈利税 100% 直接给 profitAddress（用于回购销毁）
            IERC20(_USDT).transferFrom(
                address(distributor),
                profitAddress,
                amount
            );
        }
    }

    // 为 SF 池添加流动性
    function swapAndLiquifySF(uint256 tokens) internal {
        IERC20 SFERC20 = IERC20(_SF);
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;
        uint256 initialBalance = SFERC20.balanceOf(address(distributor));
        swapTokenForSf(half, address(distributor));
        uint256 afterBalance = SFERC20.balanceOf(address(distributor));
        if (afterBalance <= initialBalance) {
            return;
        }
        uint256 newBalance = afterBalance - initialBalance;
        SFERC20.transferFrom(address(distributor), address(this), newBalance);
        addLiquiditySF(otherHalf, newBalance);
    }

    // 将 SFK 换成 SF
    function swapTokenForSf(uint256 tokenAmount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_SF);
        
        uint256 sfAmount = getSfAmountsOut(tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            (sfAmount * 55) / 100,
            path,
            to,
            block.timestamp
        );
    }

    // 添加 SF/SFK 流动性
    function addLiquiditySF(uint256 tokenAmount, uint256 sfAmount) internal {
        uint256 amountTokenMin = (tokenAmount * 95) / 100;
        uint256 amountSfMin = (sfAmount * 95) / 100;
        uniswapV2Router.addLiquidity(
            address(this),
            address(_SF),
            tokenAmount,
            sfAmount,
            amountTokenMin,
            amountSfMin,
            address(0xdead),
            block.timestamp
        );
    }

    // function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) internal {
    //     // 设置滑点 5%
    //     uint256 amountTokenMin = (tokenAmount * 95) / 100;
    //     uint256 amountUsdtMin = (usdtAmount * 95) / 100;
    //     uniswapV2Router.addLiquidity(
    //         address(this),
    //         address(_USDT),
    //         tokenAmount,
    //         usdtAmount,
    //         amountTokenMin,
    //         amountUsdtMin,
    //         address(0xdead),
    //         block.timestamp
    //     );
    // }
    function addLiquidityUSDT(uint256 tokenAmount, uint256 usdtAmount) internal {
        uint256 amountTokenMin = (tokenAmount * 95) / 100;
        uint256 amountUsdtMin = (usdtAmount * 95) / 100;
        uniswapV2Router.addLiquidity(
            address(this),
            address(_USDT),
            tokenAmount,
            usdtAmount,
            amountTokenMin,
            amountUsdtMin,
            address(0xdead),
            block.timestamp
        );
    }

    function swapTokenForUsdt(uint256 tokenAmount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_USDT);

        uint256 uAmount = getUsdtAmountsOut(tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            (uAmount * 55) / 100,
            path,
            to,
            block.timestamp
        );
    }

    // function swapAndLiquify(uint256 tokens) internal {
    //     IERC20 USDTERC20 = IERC20(_USDT);
    //     uint256 half = tokens / 2;
    //     uint256 otherHalf = tokens - half;
    //     uint256 initialBalance = USDTERC20.balanceOf(address(distributor));
    //     swapTokenForUsdt(half, address(distributor));
    //     uint256 afterBalance = USDTERC20.balanceOf(address(distributor));
    //     if (afterBalance <= initialBalance) {
    //         return;
    //     }
    //     uint256 newBalance = afterBalance - initialBalance;
    //     USDTERC20.transferFrom(address(distributor), address(this), newBalance);
    //     addLiquidity(otherHalf, newBalance);
    // }
    function swapAndLiquifyUSDT(uint256 tokens) internal {
        IERC20 USDTERC20 = IERC20(_USDT);
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;
        uint256 initialBalance = USDTERC20.balanceOf(address(distributor));
        swapTokenForUsdt(half, address(distributor));
        uint256 afterBalance = USDTERC20.balanceOf(address(distributor));
        if (afterBalance <= initialBalance) {
            return;
        }
        uint256 newBalance = afterBalance - initialBalance;
        USDTERC20.transferFrom(address(distributor), address(this), newBalance);
        addLiquidityUSDT(otherHalf, newBalance);
    }

    function swapSfForUsdt(uint256 sfAmount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(_SF);
        path[1] = address(_USDT);
        
        uint[] memory amountsOut = uniswapV2Router.getAmountsOut(sfAmount, path);
        uint256 expectedUsdt = amountsOut[1];
        
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sfAmount,
            (expectedUsdt * 55) / 100,
            path,
            to,
            block.timestamp
        );
    }

    // 这个需要如何修改？
    // function recycle(uint256 amount) external {
    //     require(STAKING == msg.sender, "cycle");
    //     uint256 maxBurn = balanceOf(uniswapV2Pair) / 3;
    //     uint256 burnAmount = amount >= maxBurn ? maxBurn : amount;
    //     super._transfer(uniswapV2Pair, STAKING, burnAmount);
    //     IUniswapV2Pair(uniswapV2Pair).sync();
    // }
    
    function recycleUSDT(uint256 amount) external {
        require(STAKING == msg.sender, "cycle");
        uint256 maxBurn = balanceOf(uniswapV2PairUSDT) / 3;
        uint256 burnAmount = amount >= maxBurn ? maxBurn : amount;
        super._transfer(uniswapV2PairUSDT, STAKING, burnAmount);
        IUniswapV2Pair(uniswapV2PairUSDT).sync();
    }

    function recycleSF(uint256 amount) external {
        require(STAKING == msg.sender, "cycle");
        uint256 maxBurn = balanceOf(uniswapV2PairSF) / 3;
        uint256 burnAmount = amount >= maxBurn ? maxBurn : amount;
        super._transfer(uniswapV2PairSF, STAKING, burnAmount);
        IUniswapV2Pair(uniswapV2PairSF).sync();
    }
    // ==========================================

    function setPresale() external onlyOwner {
        presale = true;
        launch();
        updatePoolReserveUSDT();
        updatePoolReserveSF();
    }

    function setColdTime(uint40 _coldTime) external onlyOwner {
        coldTime = _coldTime;
    }

    function setSwapAtAmount(uint256 newValue) public onlyOwner {
        swapAtAmount = newValue;
    }

    function setTechAddress(address addr) external onlyOwner {
        techAddress = addr;
        excludeFromFee(addr);
    }

    function setProfitAddress(address addr) external onlyOwner {
        profitAddress = addr;
        excludeFromFee(addr);
    }

    function setNFTNodeAddress(address addr) external onlyOwner {
        require(addr != address(0), "Invalid address");
        NFTNodeAddress = addr;
        excludeFromFee(addr);
    }

    function setStaking(address addr) external onlyOwner {
        STAKING = addr;
        excludeFromFee(addr);
    }

    function setBatchRewardList(
        address[] calldata addresses,
        bool value
    ) public onlyOwner {
        require(
            addresses.length < 201,
            "Address array length exceeds maximum limit"
        );
        for (uint256 i; i < addresses.length; ++i) {
            _rewardList[addresses[i]] = value;
        }
    }

    function isReward(address account) public view returns (bool) {
        return _rewardList[account];
    }
}
