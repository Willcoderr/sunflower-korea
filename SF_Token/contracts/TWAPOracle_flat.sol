pragma solidity ^0.8.20;


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

interface ITWAPOracle {
    
    function getDailyClosePrice() external view returns (uint256 price);
    
    
    function getTokenDailyClosePriceInUSDT() external view returns (uint256 price);
    
    
    function getCurrentPrice() external view returns (uint256 price);
    
    
    function getTokenCurrentPriceInUSDT() external view returns (uint256 price);
    
    
    function getPriceChangeBps() external view returns (int256 priceChangeBps);
    
    
    function setUSDTAddress(address _usdtAddress) external;
}

abstract contract Owned {
    
contract TWAPOracle is ITWAPOracle, Owned {
    
    
    struct PairInfo {
        address pairAddress;    
        address token0Address;  
        address token1Address;  
        bool isToken0Tracked;   
    }
    
    
    
    address public immutable trackedToken;      
    address public immutable quoteToken;         
    address public usdtAddress;                  
    
    PairInfo public pairInfo;                     
    
    
    uint256 public lastDailyClosePrice;          
    uint256 public lastDailyCloseDay;            
    
    
    mapping(address => bool) public admins;
    
    
    
    event DailyClosePriceUpdated(uint256 day, uint256 price);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event USDTAddressSet(address indexed usdtAddress);
    event PairInfoUpdated(address indexed pairAddress, address token0, address token1, bool isToken0Tracked);
    
    
    
    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner, "Not authorized admin");
        _;
    }
    
    
    
    
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
        usdtAddress = _quoteToken; 
        
        
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
    
    
    
    
    function updateDailyClosePrice() external onlyAdmin {
        uint256 currentDay = block.timestamp / 1 days;
        
        
        if (lastDailyCloseDay < currentDay) {
            
            uint256 currentPrice = getTokenCurrentPriceInUSDT();
            require(currentPrice > 0, "Invalid current price");
            
            lastDailyClosePrice = currentPrice;
            lastDailyCloseDay = currentDay;
            
            emit DailyClosePriceUpdated(currentDay, currentPrice);
        }
    }
    
    
    function setDailyClosePrice(uint256 price, uint256 day) external onlyAdmin {
        require(price > 0, "Invalid price");
        require(day > 0, "Invalid day");
        
        lastDailyClosePrice = price;
        lastDailyCloseDay = day;
        
        emit DailyClosePriceUpdated(day, price);
    }
    
    
    
    
    function getCurrentPrice() external view override returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairInfo.pairAddress);
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        
        require(reserve0 > 0 && reserve1 > 0, "No liquidity");
        
        if (pairInfo.isToken0Tracked) {
            
            return (uint256(reserve1) * 1e18) / reserve0;
        } else {
            
            return (uint256(reserve0) * 1e18) / reserve1;
        }
    }
    
    
    function getTokenCurrentPriceInUSDT() public view override returns (uint256) {
        return this.getCurrentPrice();
    }
    
    
    function getDailyClosePrice() external view override returns (uint256) {
        if (lastDailyClosePrice == 0) {
            
            return getTokenCurrentPriceInUSDT();
        }
        return lastDailyClosePrice;
    }
    
    
    function getTokenDailyClosePriceInUSDT() external view override returns (uint256) {
        return this.getDailyClosePrice();
    }
    
    
    
    
    function getPriceChangeBps() external view override returns (int256) {
        uint256 currentPrice = getTokenCurrentPriceInUSDT();
        uint256 closePrice = this.getDailyClosePrice();
        
        if (closePrice == 0 || currentPrice == 0) {
            return 0;
        }
        
        
        if (currentPrice >= closePrice) {
            
            uint256 change = ((currentPrice - closePrice) * 10000) / closePrice;
            return int256(change);
        } else {
            
            uint256 change = ((closePrice - currentPrice) * 10000) / closePrice;
            return -int256(change);
        }
    }
    
    
    
    
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
    
    
    
    
    function setPairInfo(address _pairAddress) external onlyOwner {
        require(_pairAddress != address(0), "Invalid pair address");
        
        
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);
        address token0 = pair.token0();
        address token1 = pair.token1();
        
        require(token0 != address(0) && token1 != address(0), "Invalid pair tokens");
        
        bool isToken0Tracked = (token0 == trackedToken);
        require(
            (token0 == trackedToken || token1 == trackedToken),
            "Tracked token not in pair"
        );
        
        
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
    
    
    function setUSDTAddress(address _usdtAddress) external override onlyOwner {
        require(_usdtAddress != address(0), "Invalid USDT address");
        usdtAddress = _usdtAddress;
        emit USDTAddressSet(_usdtAddress);
    }
    
    
    function addAdmin(address admin) external onlyOwner {
        require(admin != address(0), "Invalid admin address");
        admins[admin] = true;
        emit AdminAdded(admin);
    }
    
    
    function removeAdmin(address admin) external onlyOwner {
        admins[admin] = false;
        emit AdminRemoved(admin);
    }
}