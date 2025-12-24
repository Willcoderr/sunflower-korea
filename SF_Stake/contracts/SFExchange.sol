// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;


import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {Owned} from "solmate/src/auth/Owned.sol";
import "./interface/ISF.sol";
import "./interface/ISFExchange.sol";
import {_SF, _USDT,_SFK, _ROUTER} from "./Const.sol";

contract SFExchange is ISFExchange, Owned {
    ISFErc20 public SF = ISFErc20(_SF);
    IERC20 public USDT = IERC20(_USDT);
    IERC20 public SFK = IERC20(_SFK);
    IUniswapV2Router02 public immutable ROUTER = IUniswapV2Router02(_ROUTER);

    address public stakingContract;  // 只允许质押合约调用
    
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

    function exchangeUSDTForSF(uint256 usdtAmount) external override onlyStaking returns (uint256 sfAmount) {
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        
        sfAmount = calculateSFAmount(usdtAmount);
        
        require(SF.balanceOf(address(this)) >= sfAmount + minSFReserve, "Insufficient SF reserve");
        
        SF.transfer(msg.sender, sfAmount);
        
        emit ExchangeUSDTForSF(msg.sender, usdtAmount, sfAmount);
    }

    function exchangeSFForUSDT(uint256 sfAmount) external override onlyStaking returns (uint256 usdtAmount) {
        SF.transferFrom(msg.sender, address(this), sfAmount);
        
        usdtAmount = calculateUSDTAmount(sfAmount);
        
        require(USDT.balanceOf(address(this)) >= usdtAmount + minUSDTReserve, "Insufficient USDT reserve");
        
        USDT.transfer(msg.sender, usdtAmount);
        
        emit ExchangeSFForUSDT(msg.sender, sfAmount, usdtAmount);
    }
    

    function depositFromWhitelist(uint256 sfAmount, uint256 usdtAmount) external override onlyOwner {
        if (sfAmount > 0) {
            SF.transferFrom(msg.sender, address(this), sfAmount);
        }
        if (usdtAmount > 0) {
            USDT.transferFrom(msg.sender, address(this), usdtAmount);
        }
        emit WhitelistDeposit(msg.sender, sfAmount, usdtAmount);
    }
    

    function setStakingContract(address _stakingContract) external override onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        address oldContract = stakingContract;
        stakingContract = _stakingContract;
        emit StakingContractUpdated(oldContract, _stakingContract);
    }
    

    function setReserveThresholds(uint256 _minSFReserve, uint256 _minUSDTReserve) external override onlyOwner {
        minSFReserve = _minSFReserve;
        minUSDTReserve = _minUSDTReserve;
        emit ReserveThresholdUpdated(_minSFReserve, _minUSDTReserve);
    }
    

    function emergencyWithdraw(address token, uint256 amount, address to) external override onlyOwner {
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
    

    function getConfig() external view override returns (
        uint256 _minSFReserve,
        uint256 _minUSDTReserve,
        address _stakingContract
    ) {
        _minSFReserve = minSFReserve;
        _minUSDTReserve = minUSDTReserve;
        _stakingContract = stakingContract;
    }
}
