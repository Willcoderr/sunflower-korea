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

address constant _USDT = 0xC6961C826cAdAC9b85F444416D3bf0Ca2a1c38CA;
address constant _SF = 0x9af8d66Fc14beC856896771fD7D2DB12b41ED9E8;
address constant _SFK = 0xb362f8372cE0EF2265E9988292d17abfEB96473f;
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
    function getReserveUSDT() external view returns (uint112);
    function getReserveSF() external view returns (uint112);

    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IStakingReward {
    function emitUnstakePerformanceUpdate(address user,uint256 amount) external;
    function setSettlementProfitUsdt(bytes32 settlementId, uint256 profitUsdt) external;
}

abstract contract Owned {
                                 EVENTS

    event OwnershipTransferred(address indexed user, address indexed newOwner);

                            OWNERSHIP STORAGE

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

                               CONSTRUCTOR

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

                             OWNERSHIP LOGIC

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

library Math {
    function min(uint40 a, uint40 b) internal pure returns (uint40) {
        return a < b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

abstract contract Referral {
    mapping(address => address) private _parentOf;
    mapping(address => bool) private _isBound;
    mapping(address => uint256) private _directCount;
    address[] private _allUsers;
    address private _root;
    event BindReferral(address indexed user, address parent);

    constructor() {
        _root = msg.sender;
        _isBound[_root] = true;
        _parentOf[_root] = address(0);
        _allUsers.push(_root);
    }

    function getReferral(address _address) public view returns (address) {
        return _parentOf[_address];
    }

    function isBindReferral(address _address) public view returns (bool) {
        return _isBound[_address];
    }

    function getReferralCount(address _address) public view returns (uint256) {
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
        unchecked {
            _directCount[_referral] += 1;
        }

        emit BindReferral(_user, _referral);
    }

    function getReferrals(
        address _address,
        uint256 _num
    ) public view returns (address[] memory) {
        address[] memory ups = new address[](_num);
        address cur = _parentOf[_address];
        uint256 i = 0;
        while (cur != address(0) && i < _num) {
            ups[i] = cur;
            unchecked {
                i++;
            }
            cur = _parentOf[cur];
        }
        if (i < _num) {
            assembly {
                mstore(ups, i)
            }
        }
        return ups;
    }

    function getRootAddress() public view returns (address) {
        return _root;
    }

    function getUsersCount() public view returns (uint256) {
        return _allUsers.length;
    }

    function getUsers(
        uint256 fromId,
        uint256 toId
    ) public view returns (address[] memory addrArr) {
        require(fromId <= toId, "fromId > toId");
        require(toId <= _allUsers.length, "exist num!");
        require(fromId <= _allUsers.length, "exist num!");
        addrArr = new address[](toId - fromId + 1);
        uint256 i = 0;
        for (uint256 ith = fromId; ith <= toId; ith++) {
            addrArr[i] = _allUsers[ith];
            i = i + 1;
        }
        return (addrArr);
    }
}

contract Staking is Referral, Owned, ReentrancyGuard {
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 timestamp,
        uint256 index,
        uint256 stakeTime
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Unstake(
        address indexed user,
        uint256 reward,
        uint40 timestamp,
        uint256 index
    );
    event RewardOnly(
        address indexed user,
        uint256 reward,
        uint40 timestamp,
        uint256 index
    );
    event UnstakeSFToWhitelist(
        address indexed user,
        uint256 sfAmount,
        uint256 expectedUsdtValue,
        uint256 actualUsdtGot,
        uint40 timestamp
    );
    event ExchangeReserveLow(
        address indexed token,
        uint256 currentReserve,
        uint256 requiredReserve,
        uint40 timestamp
    );
    event NewReferralReward(
        address indexed user,
        address indexed referral,
        uint256 reward,
        uint256 generation,
        uint40 timestamp
    );
    event NewTeamReward(
        address indexed user,
        uint256 level,
        uint256 reward,
        uint40 timestamp
    );
    event TeamLevelUpdated(
        address indexed user,
        uint256 previousLevel,
        uint256 newLevel,
        uint256 kpi,
        uint40 timestamp
    );
    event ProfitPending(
        address indexed user,
        bytes32 indexed settlementId,
        uint256 principalUsdt,
        uint256 profitUsdt,
        uint40 ts,
        uint256 index
    );

    uint256[3] rates = [
        1000000003463000000,
        1000000006917000000,
        1000000014950000000
    ];
    uint256[3] stakeDays = [1 days, 15 days, 30 days];
    uint40 public constant timeStep = 1 days;

    IUniswapV2Router02 constant ROUTER = IUniswapV2Router02(_ROUTER);
    IERC20 constant USDT = IERC20(_USDT);

    ISFErc20 public SF;
    ISFK public SFK;

    ISFExchange public sfExchange;
    IStakingReward public stakingReward;

    address constant addressProfitUser =
        0x5E77DEEe08b98881fdd4eDB3642fEAB78C443C42;
    address constant addressProfit2NFT =
        0xD3da2a27DFCb59e002727B0E0EffEe1ddC732aaE;
    address constant addressProfit2Team =
        0x246C829bF0A8ACaF802dB52d7894605B4C4f1E59;
    address constant addressProfit2V5 =
        0x341625c5D89f161f1EEF35D2b110fC096A42AeFB;
    address constant fundAddress = 0x485199875526eC576838967207af1B8624C9F1d1;
    address constant profitAddress = 0xa65d295c38133f1a2FdfcA674712FdEEcc839aE9;

    address constant sfSwapAddress = 0x0047ebb57DB94aa193289258d48BA62f43bb8c60;

    address public eoaWithdrawAddress;

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

    uint8 constant maxDepth = 2;

    RecordTT[] public t_supply;
    uint256 public mMinSwapRatioUsdt = 50;
    uint256 public mMinSwapRatioToken = 50;
    uint256 startTime = 0;
    uint256 constant network1InTime = 90 days;
    bool bStart = false;

    mapping(uint256 => uint256) public tenSecondStakeAmount;
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

    function getNowTIme() external view returns (uint256) {
        return block.timestamp;
    }

    function setEoaWithdrawAddress(address _eoaAddress) external onlyOwner {
        eoaWithdrawAddress = _eoaAddress;
    }

    function getParameters(
        address account
    ) public view returns (uint256[] memory) {
        uint256[] memory paraList = new uint256[](uint256(20));
        uint256 ith = 0;
        paraList[ith] = 0;
        if (bStart && block.timestamp > startTime) paraList[ith] = 1;
        ith = ith + 1;
        paraList[ith] = startTime;
        ith = ith + 1;
        paraList[ith] = totalSupply;
        ith = ith + 1;
        paraList[ith] = balances[account];
        ith = ith + 1;
        paraList[ith] = balanceOf(account);
        ith = ith + 1;
        paraList[ith] = maxStakeAmount();
        ith = ith + 1;
        paraList[ith] = userStakeRecord[account].length;
        ith = ith + 1;
        paraList[ith] = getTeamKpi(account);
        ith = ith + 1;
        paraList[ith] = 0;
        if (isPreacher(account)) paraList[ith] = 1;
        ith = ith + 1;
        paraList[ith] = 0;
        if (isBindReferral(account)) paraList[ith] = 1;
        ith = ith + 1;
        paraList[ith] = upProfitSum[account];
        ith = ith + 1;
        paraList[ith] = teamProfitSum[account];
        ith = ith + 1;

        return paraList;
    }

    function balanceOf(address account) public view returns (uint256 balance) {
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

    function _updateMinuteStakeAmount(uint256 amount) private {
        uint256 currentBucket = block.timestamp / 10 seconds;

        tenSecondStakeAmount[currentBucket] += amount;
        lastUpdatedBucket = currentBucket;
    }

    function network1In() public view returns (uint256 value) {
        if (block.timestamp > startTime + network1InTime) {
            return 0 ether;
        }

        uint256 windowStart = block.timestamp - 1 minutes;
        uint256 windowEnd = block.timestamp;

        uint256 startBucket = windowStart / 10 seconds;
        uint256 endBucket = windowEnd / 10 seconds;

        value = 0;
        for (uint256 bucket = startBucket; bucket <= endBucket; bucket++) {
            value += tenSecondStakeAmount[bucket];
        }

        return value;
    }

    function canStakeAmount() public view returns (uint256) {
        uint256 amout0 = 0;
        if (startTime == 0) return amout0;
        if (block.timestamp < startTime) return amout0;

        uint256 daysElapsed = (block.timestamp - startTime) / 1 days;

        amout0 = 200 ether + daysElapsed * (100 ether);

        if (amout0 > 2000 ether) amout0 = 2000 ether;
        return amout0;
    }

    function maxStakeAmount() public view returns (uint256) {
        uint256 lastIn = network1In();
        uint256 canStakV = canStakeAmount();

        if (lastIn > canStakV) return 0;

        uint256 remaining = canStakV - lastIn;

        uint256 reverseu = SFK.getReserveUSDT();
        uint256 sfReserve = SFK.getReserveSF();
        uint256 usdtOut = quoteSFInUSDT(sfReserve);
        reverseu = reverseu + usdtOut;

        if (canStakV >= 2000 ether) {
            uint256 poolLimit = reverseu / 500;

            if (poolLimit < 2000 ether) {
                poolLimit = 2000 ether;
            }

            if (remaining > poolLimit) {
                remaining = poolLimit;
            }
        } else {
            uint256 p1 = reverseu / 500;
            if (remaining > p1) {
                remaining = p1;
            }
        }

        return remaining;
    }

    function quoteSFInUSDT(
        uint256 sfAmount
    ) public view returns (uint256 usdtOut) {
        if (sfAmount == 0) return 0;
        address[] memory path = new address[](3);
        path[0] = address(SF);
        path[1] = address(SFK);
        path[2] = address(USDT);
        uint256[] memory amountsOut = ROUTER.getAmountsOut(sfAmount, path);
        return amountsOut[2];
    }

    function rewardOfSlot(
        address user,
        uint256 index
    ) public view returns (uint256 reward) {
        Record storage user_record = userStakeRecord[user][index];
        return caclItem(user_record);
    }

    function getTeamKpi(address _user) public view returns (uint256) {
        return teamTotalInvestValue[_user] + teamVirtuallyInvestValue[_user];
    }

    function getTeamInfos(
        address[] memory addrArr
    )
        external
        view
        returns (
            uint256[] memory kpiArr,
            uint256[] memory balancesArr,
            bool[] memory isPreacherArr,
            bool[] memory isV5Arr
        )
    {
        kpiArr = new uint256[](addrArr.length);
        balancesArr = new uint256[](addrArr.length);
        isPreacherArr = new bool[](addrArr.length);
        isV5Arr = new bool[](addrArr.length);
        for (uint256 i = 0; i < addrArr.length; i++) {
            kpiArr[i] = getTeamKpi(addrArr[i]);
            balancesArr[i] = balances[addrArr[i]];
            isPreacherArr[i] = isPreacher(addrArr[i]);
            isV5Arr[i] = (kpiArr[i] > 500000 * 10 ** 18);
        }
        return (kpiArr, balancesArr, isPreacherArr, isV5Arr);
    }

    function isPreacher(address user) public view returns (bool) {
        return balances[user] >= 200e18;
    }

    function userStakeCount(
        address user
    ) external view returns (uint256 count) {
        count = userStakeRecord[user].length;
    }

    function _getStakeRecordInfo(
        Record storage user_record,
        uint256 currentTime
    ) private view returns (uint256 reward, uint256 canEndData, bool bEndData) {
        if (!user_record.status) {
            reward = caclItem(user_record);
        }
        canEndData =
            user_record.oriStakeTime +
            stakeDays[user_record.stakeIndex];
        bEndData = canEndData < currentTime;
    }

    function userStakeInfo(
        address user,
        uint8 index
    )
        external
        view
        returns (
            uint256 oriStakeTime,
            uint256 stakeTime,
            uint256 amount,
            bool status,
            uint256 stakeIndex,
            uint256 reward,
            uint256 canEndData,
            bool bEndData
        )
    {
        Record storage user_record = userStakeRecord[user][index];
        oriStakeTime = uint256(user_record.oriStakeTime);
        stakeTime = uint256(user_record.stakeTime);
        amount = uint256(user_record.amount);
        status = user_record.status;
        stakeIndex = uint256(user_record.stakeIndex);
        (reward, canEndData, bEndData) = _getStakeRecordInfo(
            user_record,
            block.timestamp
        );
    }

    function userStakeInfos(
        address user
    )
        external
        view
        returns (
            uint256[] memory oriStakeTimeArr,
            uint256[] memory stakeTimeArr,
            uint256[] memory amountArr,
            bool[] memory statusArr,
            uint256[] memory stakeIndexArr,
            uint256[] memory rewardArr,
            uint256[] memory canEndDataArr,
            bool[] memory bEndDataArr
        )
    {
        Record[] storage cord = userStakeRecord[user];
        if (cord.length <= 0)
            return (
                oriStakeTimeArr,
                stakeTimeArr,
                amountArr,
                statusArr,
                stakeIndexArr,
                rewardArr,
                canEndDataArr,
                bEndDataArr
            );
        oriStakeTimeArr = new uint256[](cord.length);
        stakeTimeArr = new uint256[](cord.length);
        amountArr = new uint256[](cord.length);
        statusArr = new bool[](cord.length);
        stakeIndexArr = new uint256[](cord.length);
        rewardArr = new uint256[](cord.length);
        canEndDataArr = new uint256[](cord.length);
        bEndDataArr = new bool[](cord.length);
        uint256 nowTime = block.timestamp;
        for (uint256 i = 0; i < cord.length; i++) {
            Record storage user_record = cord[i];
            oriStakeTimeArr[i] = uint256(user_record.oriStakeTime);
            stakeTimeArr[i] = uint256(user_record.stakeTime);
            amountArr[i] = uint256(user_record.amount);
            statusArr[i] = user_record.status;
            stakeIndexArr[i] = uint256(user_record.stakeIndex);
            (
                rewardArr[i],
                canEndDataArr[i],
                bEndDataArr[i]
            ) = _getStakeRecordInfo(user_record, nowTime);
        }
        return (
            oriStakeTimeArr,
            stakeTimeArr,
            amountArr,
            statusArr,
            stakeIndexArr,
            rewardArr,
            canEndDataArr,
            bEndDataArr
        );
    }

    function allRecordLength() external view returns (uint256 allRecordLen) {
        allRecordLen = t_supply.length;
    }

    function allRecordInfos(
        uint256 fromId,
        uint256 toId
    )
        external
        view
        returns (uint256[] memory timeArr, uint256[] memory amountArr)
    {
        require(fromId <= toId, "fromId > toId");
        require(toId < t_supply.length, "toId out of range");
        timeArr = new uint256[](toId - fromId + 1);
        amountArr = new uint256[](toId - fromId + 1);

        uint256 i = 0;
        for (uint256 ith = fromId; ith <= toId; ith++) {
            timeArr[i] = uint256(t_supply[ith].stakeTime);
            amountArr[i] = uint256(t_supply[ith].tamount);
            i = i + 1;
        }
        return (timeArr, amountArr);
    }

    function _stakeInternal(
        uint160 _amount,
        uint8 _stakeIndex,
        address parent
    ) private {
        require(bStart, "ERC721: not Start");
        require(block.timestamp > startTime, "not Start!");
        require(_amount <= maxStakeAmount(), "<1000");
        require(_stakeIndex <= 2, "<=2");
        require(userStakeRecord[msg.sender].length < 200, "stake too long");

        address user = msg.sender;

        if (parent != address(0) && !isBindReferral(user)) {
            require(isBindReferral(parent), "Parent not bound");
            bindReferral(parent, user);
        }

        require(isBindReferral(user), "Must bind referral");

        swapAndAddLiquidity(_amount);

        mint(user, _amount, _stakeIndex);
    }

    function stake(
        uint160 _amount,
        uint8 _stakeIndex
    ) external onlyEOA nonReentrant {
        _stakeInternal(_amount, _stakeIndex, address(0));
    }

    function stakeWithInviter(
        uint160 _amount,
        uint8 _stakeIndex,
        address parent
    ) external onlyEOA nonReentrant {
        _stakeInternal(_amount, _stakeIndex, parent);
    }

    function getTokenAmountsOut(
        uint amountUsdt
    ) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SFK);

        uint[] memory amountsOut = ROUTER.getAmountsOut(amountUsdt, path);
        price = amountsOut[1];
    }

    function getUsdtAmountsOut(
        uint amountToken
    ) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(SFK);
        path[1] = address(USDT);

        uint[] memory amountsOut = ROUTER.getAmountsOut(amountToken, path);
        price = amountsOut[1];
    }

    function swapUsdtForTokens(uint256 uAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SFK);

        uint256 tokenAmount = getTokenAmountsOut(uAmount);

        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uAmount,
            (tokenAmount * mMinSwapRatioToken) / 100,
            path,
            to,
            block.timestamp
        );
    }

    function swapAndAddLiquidity(uint160 _amount) private {
        require(address(sfExchange) != address(0), "SFExchange not set");

        USDT.transferFrom(msg.sender, address(this), _amount);

        uint256 halfAmount = _amount / 2;

        uint256 usdtForSwap = halfAmount / 2;

        uint256 usdtForLiquidity = halfAmount / 2;

        uint256 sfkAmount1 = swapUsdtForSFK(usdtForSwap, address(this));

        addLiquidityUSDTSFK(usdtForLiquidity, sfkAmount1, address(0xdead));

        USDT.approve(address(sfExchange), halfAmount);
        uint256 actualSF = sfExchange.exchangeUSDTForSF(halfAmount);

        uint256 sfForSwap = actualSF / 2;
        uint256 sfForLiquidity = actualSF / 2;

        SF.approve(address(ROUTER), sfForSwap);

        uint256 sfkAmount = swapSFForSFK(sfForSwap, address(this));

        addLiquiditySFSFK(sfForLiquidity, sfkAmount, address(0xdead));
    }

    function swapSFKForSF(
        uint256 sfkAmount,
        address to
    ) private returns (uint256) {
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

    function swapSFKForUSDT(
        uint256 sfkAmount,
        address to
    ) private returns (uint256) {
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

    function swapSFForSFK(
        uint256 sfAmount,
        address to
    ) private returns (uint256) {
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

    function calculateRequiredSF(
        uint256 usdtAmount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SF);

        uint[] memory amounts = ROUTER.getAmountsOut(usdtAmount, path);
        return amounts[1];
    }

    function swapUsdtForSFK(
        uint256 uAmount,
        address to
    ) private returns (uint256) {
        uint256 sfkBefore = SFK.balanceOf(to);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SFK);
        uint[] memory amountsOut = ROUTER.getAmountsOut(uAmount, path);
        USDT.approve(address(ROUTER), type(uint256).max);
        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uAmount,
            (amountsOut[1] * mMinSwapRatioToken) / 100,
            path,
            to,
            block.timestamp
        );
        return SFK.balanceOf(to) - sfkBefore;
    }

    function addLiquiditySFSFK(
        uint256 sfAmount,
        uint256 sfkAmount,
        address to
    ) private {
        SF.approve(address(ROUTER), type(uint256).max);
        SFK.approve(address(ROUTER), type(uint256).max);
        ROUTER.addLiquidity(
            address(SF),
            address(SFK),
            sfAmount,
            sfkAmount,
            (sfAmount * mMinSwapRatioToken) / 100,
            (sfkAmount * mMinSwapRatioToken) / 100,
            to,
            block.timestamp
        );
    }

    function addLiquidityUSDTSFK(
        uint256 usdtAmount,
        uint256 sfkAmount,
        address to
    ) private {
        USDT.approve(address(ROUTER), type(uint256).max);
        SFK.approve(address(ROUTER), type(uint256).max);
        ROUTER.addLiquidity(
            address(USDT),
            address(SFK),
            usdtAmount,
            sfkAmount,
            (usdtAmount * mMinSwapRatioUsdt) / 100,
            (sfkAmount * mMinSwapRatioToken) / 100,
            to,
            block.timestamp
        );
    }

    function addLiquidityTokenToken(
        uint usdtAmount,
        uint tokenAmount,
        address to
    ) private {
        ROUTER.addLiquidity(
            address(USDT),
            address(SF),
            usdtAmount,
            tokenAmount,
            (usdtAmount * mMinSwapRatioUsdt) / 100,
            (tokenAmount * mMinSwapRatioToken) / 100,
            to,
            block.timestamp
        );
    }

    function mint(address sender, uint160 _amount, uint8 _stakeIndex) private {
        require(isBindReferral(sender), "!!bind");
        RecordTT memory tsy;
        tsy.stakeTime = uint40(block.timestamp);
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

        _updateMinuteStakeAmount(_amount);

        Record[] storage cord = userStakeRecord[sender];
        uint256 stake_index = cord.length;
        cord.push(order);

        emit Transfer(address(0), sender, _amount);
        emit Staked(
            sender,
            _amount,
            block.timestamp,
            stake_index,
            stakeDays[_stakeIndex]
        );
    }

    function caclItem(
        Record storage user_record
    ) private view returns (uint256 reward) {
        uint256 stake_amount = user_record.amount;
        uint40 stake_time = user_record.stakeTime;
        uint40 endTime = uint40(block.timestamp);

        uint256 maxStakeDuration = stakeDays[user_record.stakeIndex];
        if (endTime > user_record.oriStakeTime + maxStakeDuration) {
            endTime = uint40(user_record.oriStakeTime + maxStakeDuration);
        }

        if (endTime <= stake_time) {
            reward = stake_amount;
            return reward;
        }

        uint40 stake_period = endTime - stake_time;

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

    function powu(
        uint256 base,
        uint256 exp
    ) internal pure returns (uint256 result) {
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
        uint256 reward;
        uint256 stake;
        uint256 sfkBefore;
        uint256 usdtBefore;
        uint256 sfBefore;
        uint256 totalUsdtValue;
        uint256 halfUsdtValue;
        uint256 usdtFromPool1;
        uint256 sfFromPool2;
        uint256 usdtFromExchange;
        uint256 totalUsdtForUser;
        uint256 principalUsdt;
        uint256 profitUsdt;
        uint256 actualSFK1Used;
        uint256 actualSFK2Used;
    }

    function unstake(
        uint256 index
    ) external onlyEOA nonReentrant returns (uint256) {
        Vars memory v;
        (v.reward, v.stake) = burn(index);

        v.sfkBefore = SFK.balanceOf(address(this));
        v.usdtBefore = USDT.balanceOf(address(this));
        v.sfBefore = SF.balanceOf(address(this));

        v.totalUsdtValue = getUsdtAmountsOut(v.reward);
        v.halfUsdtValue = v.totalUsdtValue / 2;

        address[] memory pathUsdt = new address[](2);
        pathUsdt[0] = address(SFK);
        pathUsdt[1] = address(USDT);
        uint256[] memory amountsInUsdt = ROUTER.getAmountsIn(
            v.halfUsdtValue,
            pathUsdt
        );
        uint256 requiredSFK1 = amountsInUsdt[0];

        require(
            v.sfkBefore >= requiredSFK1,
            "Insufficient SFK balance for USDT pool"
        );

        uint256 sfkBeforeSwap1 = SFK.balanceOf(address(this));

        v.usdtFromPool1 = swapSFKForUSDT(requiredSFK1, address(this));

        v.actualSFK1Used = sfkBeforeSwap1 - SFK.balanceOf(address(this));

        uint256 requiredSF = sfExchange.calculateSFAmount(v.halfUsdtValue);

        uint256 requiredSFWithBuffer = (requiredSF * 101) / 100;

        address[] memory pathSfkToSf = new address[](2);
        pathSfkToSf[0] = address(SFK);
        pathSfkToSf[1] = address(SF);
        uint256[] memory amountsInSfkToSf = ROUTER.getAmountsIn(
            requiredSFWithBuffer,
            pathSfkToSf
        );
        uint256 requiredSFK2 = amountsInSfkToSf[0];

        require(
            v.sfkBefore >= requiredSFK1 + requiredSFK2,
            "Insufficient SFK balance for SF pool"
        );

        v.sfFromPool2 = swapSFKForSF(requiredSFK2, address(this));
        v.actualSFK2Used = requiredSFK2;

        SF.approve(address(sfExchange), type(uint256).max);
        if (v.sfFromPool2 >= requiredSF) {
            v.usdtFromExchange = sfExchange.exchangeSFForUSDT(v.sfFromPool2);
            uint256 sfRemaining = v.sfFromPool2 - requiredSF;
            if (sfRemaining > 0) {
                SF.transfer(address(sfExchange), sfRemaining);
            }
        } else {
            v.usdtFromExchange = sfExchange.exchangeSFForUSDT(v.sfFromPool2);
        }

        v.totalUsdtForUser = v.usdtFromPool1 + v.usdtFromExchange;

        v.principalUsdt = getUsdtAmountsOut(v.stake);

        v.profitUsdt = 0;
        if (v.totalUsdtForUser > v.principalUsdt) {
            v.profitUsdt = v.totalUsdtForUser - v.principalUsdt;
        }

        uint256 reservedAmount = 0;
        bytes32 settlementId = bytes32(0);

        if (address(stakingReward) != address(0) && v.profitUsdt > 0) {
            reservedAmount = v.profitUsdt;
            if (
                reservedAmount > 0 &&
                v.totalUsdtForUser >= v.principalUsdt + reservedAmount
            ) {
                settlementId = keccak256(
                    abi.encodePacked(
                        block.chainid,
                        address(this),
                        msg.sender,
                        index,
                        userIndex[msg.sender],
                        block.number
                    )
                );
                USDT.transfer(address(stakingReward), reservedAmount);
                stakingReward.setSettlementProfitUsdt(
                    settlementId,
                    reservedAmount
                );
            }
        }

        if (address(stakingReward) != address(0)) {
            stakingReward.emitUnstakePerformanceUpdate(msg.sender, v.stake);
        }

        USDT.transfer(msg.sender, v.principalUsdt);

        SFK.recycleUSDT(v.actualSFK1Used);
        SFK.recycleSF(v.actualSFK2Used);

        if (settlementId != bytes32(0)) {
            emit ProfitPending(
                msg.sender,
                settlementId,
                v.principalUsdt,
                v.profitUsdt,
                uint40(block.timestamp),
                index
            );
        }

        emit UnstakeSFToWhitelist(
            msg.sender,
            v.sfFromPool2,
            v.halfUsdtValue,
            v.usdtFromExchange,
            uint40(block.timestamp)
        );

        emit Unstake(msg.sender, v.reward, uint40(block.timestamp), index);

        return v.reward;
    }

    function burn(
        uint256 index
    ) private returns (uint256 reward, uint256 amount) {
        address sender = msg.sender;
        Record[] storage cord = userStakeRecord[sender];
        Record storage user_record = cord[index];

        require(
            block.timestamp >=
                stakeDays[user_record.stakeIndex] + user_record.oriStakeTime,
            "The time is not right"
        );

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

    function calReward(
        uint256 index
    ) private returns (uint256 reward, uint256 amount) {
        address sender = msg.sender;
        Record[] storage cord = userStakeRecord[sender];
        Record storage user_record = cord[index];

        uint256 stakeTime = user_record.stakeTime;
        require(block.timestamp >= stakeTime + timeStep, "need wait");
        require(!user_record.status, "alw");

        amount = user_record.amount;
        reward = caclItem(user_record);
        user_record.stakeTime = uint40(block.timestamp);

        userIndex[sender] = userIndex[sender] + 1;
        require(reward > amount, "none reward");
        emit RewardOnly(
            msg.sender,
            reward - amount,
            uint40(block.timestamp),
            index
        );
    }

    function sync() external {
        uint256 w_bal = IERC20(USDT).balanceOf(address(this));
        address pair = SF.uniswapV2Pair();
        IERC20(USDT).transfer(pair, w_bal);
        IUniswapV2Pair(pair).sync();
    }

    function setMinSwapRatio(
        uint256 minSwapRatioUsdt,
        uint256 minSwapRatioToken
    ) external onlyOwner {
        mMinSwapRatioUsdt = minSwapRatioUsdt;
        mMinSwapRatioToken = minSwapRatioToken;
    }

    function setTeamVirtuallyInvestValue(
        address _user,
        uint256 _value
    ) external onlyOwner {
        teamVirtuallyInvestValue[_user] = _value;
    }

    function emergencyWithdrawSF(uint256 _amount) external onlyOwner {
        SF.transfer(fundAddress, _amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = payable(fundAddress).call{value: amount}("");
        require(success, "Low-level call failed");
    }

    function withdrawToken(
        address tokenAddr,
        uint256 amount
    ) external onlyOwner {
        IERC20 token = IERC20(tokenAddr);
        token.transfer(fundAddress, amount);
    }

    function setStart(bool tbstart, uint256 startT) external onlyOwner {
        bStart = tbstart;
        startTime = startT;
    }

}
