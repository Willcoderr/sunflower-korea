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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

abstract contract ReentrancyGuard {

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

address constant _USDT = 0xC6961C826cAdAC9b85F444416D3bf0Ca2a1c38CA;
address constant _SF = 0x9af8d66Fc14beC856896771fD7D2DB12b41ED9E8;
address constant _SFK = 0x33DaBa07D8b1025eE4a7Af0609722797ab70FE7d;
address constant _ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
address constant FUND_ADDRESS = 0xf3A51876c0Fb4FA7F99A62E3D6CF7d0574Aeb60d;

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
    function getReserveU() external view returns (uint112);

    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ISFExchange {

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

abstract contract Owned {

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

contract SFExchange is ISFExchange, Owned, ReentrancyGuard {
    ISFErc20 public SF = ISFErc20(_SF);
    IERC20 public USDT = IERC20(_USDT);
    IERC20 public SFK = IERC20(_SFK);
    IUniswapV2Router02 public immutable ROUTER = IUniswapV2Router02(_ROUTER);

    address public stakingContract;
    address public sfSwapAddress;
    address public usdtSwapAddress;

    uint256 public minSFReserve = 10e18;
    uint256 public minUSDTReserve = 500e18;

    constructor() Owned(msg.sender) {
        address pairAddress = SF.uniswapV2Pair();
        require(pairAddress != address(0), "SF pair not configured");
    }

    modifier onlyStaking() {
        require(msg.sender == stakingContract, "Only staking");
        _;
    }

    function exchangeUSDTForSF(uint256 usdtAmount) external override onlyStaking nonReentrant returns (uint256 sfAmount) {
        require(usdtAmount > 0, "Amount must be greater than 0");

        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        sfAmount = calculateSFAmount(usdtAmount);

        require(SF.balanceOf(address(this)) >= sfAmount + minSFReserve, "Insufficient SF reserve");

        SF.transfer(msg.sender, sfAmount);

        require(sfSwapAddress != address(0), "sfSwapAddress not set");
        USDT.transfer(sfSwapAddress, usdtAmount);

        emit ExchangeUSDTForSF(msg.sender, usdtAmount, sfAmount);
    }

    function exchangeSFForUSDT(uint256 sfAmount) external override onlyStaking nonReentrant returns (uint256 usdtAmount) {
        require(sfAmount > 0, "Amount must be greater than 0");

        SF.transferFrom(msg.sender, address(this), sfAmount);

        usdtAmount = calculateUSDTAmount(sfAmount);

        require(USDT.balanceOf(address(this)) >= usdtAmount + minUSDTReserve, "Insufficient USDT reserve");

        USDT.transfer(msg.sender, usdtAmount);

        require(usdtSwapAddress != address(0), "usdtSwapAddress not set");
        SF.transfer(usdtSwapAddress, sfAmount);

        emit ExchangeSFForUSDT(msg.sender, sfAmount, usdtAmount);
    }

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

    function setSfSwapAddress(address _sfSwapAddress) external onlyOwner {
        require(_sfSwapAddress != address(0), "Invalid address");
        address oldAddress = sfSwapAddress;
        sfSwapAddress = _sfSwapAddress;
        emit SfSwapAddressUpdated(oldAddress, _sfSwapAddress);
    }

    function setUsdtSwapAddress(address _usdtSwapAddress) external onlyOwner {
        require(_usdtSwapAddress != address(0), "Invalid address");
        address oldAddress = usdtSwapAddress;
        usdtSwapAddress = _usdtSwapAddress;
        emit UsdtSwapAddressUpdated(oldAddress, _usdtSwapAddress);
    }

    function setStakingContract(address _stakingContract) external override onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        address oldContract = stakingContract;
        stakingContract = _stakingContract;
        emit StakingContractUpdated(oldContract, _stakingContract);
    }

    function setReserveThresholds(uint256 _minSFReserve, uint256 _minUSDTReserve) external override onlyOwner {
        require(_minSFReserve <= type(uint256).max / 2, "minSFReserve too large");
        require(_minUSDTReserve <= type(uint256).max / 2, "minUSDTReserve too large");
        minSFReserve = _minSFReserve;
        minUSDTReserve = _minUSDTReserve;
        emit ReserveThresholdUpdated(_minSFReserve, _minUSDTReserve);
    }

    function emergencyWithdraw(address token, uint256 amount, address to) external override onlyOwner nonReentrant {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient");
        require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient contract balance");
        IERC20(token).transfer(to, amount);
    }

    function calculateSFAmount(uint256 usdtAmount) public view override returns (uint256) {
        require(usdtAmount > 0, "Amount must be greater than 0");

        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SF);

        uint256[] memory amountsOut = ROUTER.getAmountsOut(usdtAmount, path);
        return amountsOut[1];
    }

    function calculateUSDTAmount(uint256 sfAmount) public view override returns (uint256) {
        require(sfAmount > 0, "Amount must be greater than 0");

        address[] memory path = new address[](2);
        path[0] = address(SF);
        path[1] = address(USDT);

        uint256[] memory amountsOut = ROUTER.getAmountsOut(sfAmount, path);
        return amountsOut[1];
    }

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

    function getConfig() external view returns (
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
