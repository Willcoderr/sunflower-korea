pragma solidity ^0.8.20;

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

address constant _USDT = 0xC6961C826cAdAC9b85F444416D3bf0Ca2a1c38CA; 
address constant _SF = 0x9af8d66Fc14beC856896771fD7D2DB12b41ED9E8; 
address constant _ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; 
address constant FUND_ADDRESS = 0xf3A51876c0Fb4FA7F99A62E3D6CF7d0574Aeb60d; 
address constant NFT_ADDRESS = 0x2B1511Dc09B718f74eE8A6953a4C3eC49949f705; 

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

abstract contract Owned {
    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

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

abstract contract FirstLaunch {
    uint40 public launchedAtTimestamp;

    function launch() internal {
        require(launchedAtTimestamp == 0, "Already launched");
        launchedAtTimestamp = uint40(block.timestamp);
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

interface IReferral{
    
    event BindReferral(address indexed user,address parent);
    
    function getReferral(address _address)external view returns(address);

    function isBindReferral(address _address) external view returns(bool);

    function getReferralCount(address _address) external view returns(uint256);

    function bindReferral(address _referral,address _user) external;

    function getReferrals(address _address,uint256 _num) external view returns(address[] memory);

    function getRootAddress()external view returns(address);
}

interface IStaking {
    function balances(address) external view returns (uint256);
    function isPreacher(address) external  view returns(bool);
}

interface ITWAPOracle {
    
    function getDailyClosePrice() external view returns (uint256 price);
    
    
    function getTokenDailyClosePriceInUSDT() external view returns (uint256 price);
    
    
    function getCurrentPrice() external view returns (uint256 price);
    
    
    function getTokenCurrentPriceInUSDT() external view returns (uint256 price);
    
    
    function getPriceChangeBps() external view returns (int256 priceChangeBps);
    
    
    function setUSDTAddress(address _usdtAddress) external;
}

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

    
    
    
    

    
    uint256 public totalAmountLPFeeUSDT;
    uint256 public totalAmountNodeFee;
    uint256 public totalAmountTechFee;

    uint256 public totalAmountLPFeeSF;

    
    
    

    
    address public profitAddress = 0xFDbC769D3C7d7726e78820Dc7ea0Efd17dccCCC6;
    
    address public techAddress = 0x8D7418dD38423a07AE641c7b4CBf41dD195D7c7D;
    
    address public NFTNodeAddress = 0x86EA2cA99A9b6ea3FBbc148a25e6076e82Ab9341;
    
    
    uint256 public swapAtAmount = 20 ether;

    mapping(address => bool) public _rewardList;

    mapping(address => uint256) public tOwnedU;
    mapping(address => uint40) public lastBuyTime;
    address public STAKING;
    
    
    
    uint256 MAX_BURN_AMOUNT = 8900000 ether; 

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

    
    POOLUStatus public poolStatusUSDT; 
    POOLUStatus public poolStatusSF;   

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

    
    function getSfAmountsOut(uint amountToken) public view returns (uint price) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_SF);
        
        uint[] memory amountsOut = uniswapV2Router.getAmountsOut(amountToken, path);
        price = amountsOut[1];
    }

    
    function getUsdtValueOfSf(uint256 sfAmount) public view returns (uint256) {
        
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
        
        
        if (sender == uniswapV2PairUSDT || recipient == uniswapV2PairUSDT) {
            usdt_transfer(sender, recipient, amount);
            return;
        } 

        
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
        
        require(
            !Helper.isContract(recipient) || uniswapV2PairUSDT == recipient,
            "contract"
        );
        if (uniswapV2PairUSDT == sender) {
            
            require(presale, "pre");
            (uint112 reserveU, uint112 reserveThis) = getMyReserves(
                uniswapV2PairUSDT
            );
            require(amount <= reserveThis / 10, "max buy cap");
            updatePoolReserveUSDT(reserveU);
            uint256 amountUBuy = getUsdtAmountsOut(amount);
            tOwnedU[recipient] = tOwnedU[recipient] + amountUBuy;
            lastBuyTime[recipient] = uint40(block.timestamp);

            
            
            
            
            
            
            
            
            uint256 burnFee;
            uint256 burnAmount = balanceOf(address(0xdead));
            if (burnAmount < MAX_BURN_AMOUNT) {
                burnFee = (amount * 10) / 1000; 
                
                burnFee = MAX_BURN_AMOUNT - burnAmount > burnFee
                    ? burnFee
                    : MAX_BURN_AMOUNT - burnAmount;
                super._transfer(sender, address(0xdead), burnFee);
            }
            
            
            
            uint256 buyLPFee = (amount * 10) / 1000;
            totalAmountLPFeeUSDT += buyLPFee;
            super._transfer(sender, address(this), buyLPFee);
            
            
            uint256 buyNodeFee = (amount * 10) / 1000;
            totalAmountNodeFee += buyNodeFee;
            super._transfer(sender, address(this), buyNodeFee);

            uint256 totalFees = burnFee + buyLPFee + buyNodeFee;
            
            
            super._transfer(sender, recipient, amount - totalFees);
            
        } else if (uniswapV2PairUSDT == recipient) {
            
            require(presale, "pre");
            
            require(block.timestamp >= lastBuyTime[sender] + coldTime, "cold");
            (uint112 reserveU, uint112 reserveThis) = getMyReserves(
                uniswapV2PairUSDT
            );

            require(amount <= reserveThis / 10, "max sell cap"); 

            
            
            uint256 sellExtraFee = 0; 
            if (launchedAtTimestamp > 0 && 
                block.timestamp - launchedAtTimestamp <= 15 minutes) {
                sellExtraFee = (amount * 50) / 1000; 
            }
            
            uint256 sellLPFee = (amount * 10) / 1000; 
            uint256 sellNodeFee = (amount * 10) / 1000; 
            
            
            uint256 sellTechFee = (amount * 10) / 1000;
            
            
            int256 priceChangeBps = twapOracle.getPriceChangeBps();
            uint256 dynamicTechFee = 0;
            
            if (priceChangeBps < 0) {
                uint256 absPriceChange = uint256(-priceChangeBps); 
                if (absPriceChange >= 1300) {
                    
                    uint256 cappedPriceChange = absPriceChange > 3000 ? 3000 : absPriceChange;
                    
                    uint256 excessBps = cappedPriceChange - 1300;
                    
                    dynamicTechFee = (amount * excessBps) / 10000;
                }
            }
            
            
            sellTechFee = sellTechFee + dynamicTechFee;

            uint256 baseFee = sellLPFee + sellNodeFee + sellTechFee + sellExtraFee;
            
            
            uint256 amountUOut = getUsdtAmountsOut(amount - baseFee);
            updatePoolReserveUSDT(reserveU);

            
            uint256 profitFee = 0;
            if (tOwnedU[sender] >= amountUOut) {
                
                unchecked {
                    tOwnedU[sender] = tOwnedU[sender] - amountUOut;
                }
            } else if (tOwnedU[sender] > 0 && tOwnedU[sender] < amountUOut) {
                
                uint256 profitU = amountUOut - tOwnedU[sender];
                uint256 profitThis = getTokenAmountsOut(profitU);
                profitFee = (profitThis * 100) / 1000; 
                tOwnedU[sender] = 0;
            } else {
                
                profitFee = (amount * 100) / 1000;
                tOwnedU[sender] = 0;
            }
            
            
            uint256 totalFee = baseFee + profitFee;
            
            
            super._transfer(sender, address(this), totalFee);
            
            totalAmountLPFeeUSDT += sellLPFee;
            totalAmountNodeFee += sellNodeFee;
            totalAmountTechFee += sellTechFee;
            
            
            if (profitFee > 0) {
                if (shouldSwapProfit(profitFee)) {
                    swapProfit(profitFee, sender);
                }
            }
            
            
            if (sellExtraFee > 0) {
                if (shouldSwapProfit(sellExtraFee)) {
                    swapProfit(sellExtraFee, sender);
                }
            }

            
            if (shouldSwapTokenForFund(totalAmountLPFeeUSDT + totalAmountNodeFee + totalAmountTechFee)) {
                swapTokenForFund();
            }

            
            uint256 finalAmount = amount - totalFee;
            super._transfer(sender, recipient, finalAmount);
    
        } else {
            
        }
    }

    function sf_transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        
        require(
            !Helper.isContract(recipient) || uniswapV2PairSF == recipient,
            "contract"
        );
        
        
        
        
        

        if (uniswapV2PairSF == sender) {
            
            require(presale, "pre");
            (uint112 reserveSF, uint112 reserveThis) = getMyReserves(
                uniswapV2PairSF
            );
            require(amount <= reserveThis / 10, "max buy cap");
            updatePoolReserveSF(reserveSF);
            
            uint256 amountUBuy = getUsdtAmountsOut(amount);
            tOwnedU[recipient] = tOwnedU[recipient] + amountUBuy;
            lastBuyTime[recipient] = uint40(block.timestamp);

            
            
            
            
            
            
            
            
            uint256 burnFee;
            uint256 burnAmount = balanceOf(address(0xdead));
            if (burnAmount < MAX_BURN_AMOUNT) {
                burnFee = (amount * 10) / 1000; 
                
                burnFee = MAX_BURN_AMOUNT - burnAmount > burnFee
                    ? burnFee
                    : MAX_BURN_AMOUNT - burnAmount;
                super._transfer(sender, address(0xdead), burnFee);
            }
            
            
            
            uint256 LPFee = (amount * 10) / 1000;
            totalAmountLPFeeSF += LPFee;
            super._transfer(sender, address(this), LPFee);
            
            
            uint256 nodeFee = (amount * 10) / 1000;
            totalAmountNodeFee += nodeFee;
            super._transfer(sender, address(this), nodeFee);

            uint256 totalFees = burnFee + LPFee + nodeFee;

            
            super._transfer(sender, recipient, amount - totalFees);

        } else if (uniswapV2PairSF == recipient) {
            
            require(presale, "pre");
            
            
            require(block.timestamp >= lastBuyTime[sender] + coldTime, "cold");
            (uint112 reserveSF, uint112 reserveThis) = getMyReserves(
                uniswapV2PairSF
            );

            require(amount <= reserveThis / 10, "max sell cap");
            
            
            
            uint256 sellExtraFee = 0; 
            if (launchedAtTimestamp > 0 && 
                block.timestamp - launchedAtTimestamp <= 15 minutes) {
                sellExtraFee = (amount * 50) / 1000; 
            }
            
            uint256 sellLPFee = (amount * 10) / 1000; 
            uint256 sellNodeFee = (amount * 10) / 1000; 
            
            
            uint256 sellTechFee = (amount * 10) / 1000;
            
            
            int256 priceChangeBps = twapOracle.getPriceChangeBps();
            uint256 dynamicTechFee = 0;
            
            if (priceChangeBps < 0) {
                
                require(priceChangeBps > type(int256).min, "Price change overflow");
                uint256 absPriceChange = uint256(-priceChangeBps); 
                if (absPriceChange >= 1300) {
                    
                    uint256 cappedPriceChange = absPriceChange > 3000 ? 3000 : absPriceChange;
                    
                    uint256 excessBps = cappedPriceChange - 1300;
                    
                    dynamicTechFee = (amount * excessBps) / 10000;
                }
            }
            
            
            sellTechFee = sellTechFee + dynamicTechFee;

            uint256 baseFee = sellLPFee + sellNodeFee + sellTechFee + sellExtraFee;

            
            uint256 amountUOut = getUsdtAmountsOut(amount - baseFee);
            
            updatePoolReserveSF(reserveSF);

            
            uint256 profitFee = 0;
            
            if (tOwnedU[sender] >= amountUOut) {
                
                unchecked {
                    tOwnedU[sender] = tOwnedU[sender] - amountUOut;
                }
            } else if (tOwnedU[sender] > 0 && tOwnedU[sender] < amountUOut) {
                
                uint256 profitU = amountUOut - tOwnedU[sender];
                uint256 profitThis = getTokenAmountsOut(profitU);
                profitFee = (profitThis * 100) / 1000; 
                tOwnedU[sender] = 0;
            } else {
                
                profitFee = (amount * 100) / 1000;
                tOwnedU[sender] = 0;
            }
            
            
            uint256 totalFee = baseFee + profitFee;
       
            
            totalAmountLPFeeSF += sellLPFee;
            totalAmountNodeFee += sellNodeFee;
            totalAmountTechFee += sellTechFee;

            
            super._transfer(sender, address(this), totalFee);

            
            if (profitFee > 0) {
                if (shouldSwapProfit(profitFee)) {
                    swapProfit(profitFee, sender);
                }
            }
            
            
            if (sellExtraFee > 0) {
                if (shouldSwapProfit(sellExtraFee)) {
                    swapProfit(sellExtraFee, sender);
                }
            }
            
            
            if (shouldSwapTokenForFund(totalAmountLPFeeSF + totalAmountNodeFee + totalAmountTechFee)) {
                swapTokenForFund();
            }
            
            
            uint256 finalAmount = amount - totalFee;
            super._transfer(sender, recipient, finalAmount);
        } else {
            
        }
    }

    function shouldSwapTokenForFund(
        uint256 amount
    ) internal view returns (bool) {
        return amount >= swapAtAmount && !inSwapAndLiquify;
    }

    function swapTokenForFund() internal lockTheSwap {
        
        
        if (totalAmountLPFeeUSDT > 0) {
            swapAndLiquifyUSDT(totalAmountLPFeeUSDT);
            totalAmountLPFeeUSDT = 0;
        }

        
        if (totalAmountLPFeeSF > 0) {
            swapAndLiquifySF(totalAmountLPFeeSF);
            totalAmountLPFeeSF = 0;
        }
        
        
        if (totalAmountNodeFee > 0) {
            swapTokenForUsdt(totalAmountNodeFee, NFTNodeAddress);
            totalAmountNodeFee = 0;
        }
        
        
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
            
            
            IERC20(_USDT).transferFrom(
                address(distributor),
                profitAddress,
                amount
            );
        }
    }

    
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