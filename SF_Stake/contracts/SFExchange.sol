// SPDX-License-Identifier: UNLICENSED
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
    
    /**
     * @dev 质押时：USDT → SF（无税）
     * @param usdtAmount USDT 数量
     * @return sfAmount 返回的 SF 数量
     */
    function exchangeUSDTForSF(uint256 usdtAmount) external override onlyStaking returns (uint256 sfAmount) {
        // 1. 接收 USDT
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        
        // 2. 基于当前价格计算 SF 数量（参考 SF/USDT 池）
        sfAmount = calculateSFAmount(usdtAmount);
        
        // 3. 检查 SF 储备是否充足
        require(SF.balanceOf(address(this)) >= sfAmount + minSFReserve, "Insufficient SF reserve");
        
        // 4. 转出 SF（无税转账，因为是白名单购买的）
        SF.transfer(msg.sender, sfAmount);
        
        emit ExchangeUSDTForSF(msg.sender, usdtAmount, sfAmount);
    }
    
    /**
     * @dev 解押时：SF → USDT
     * @param sfAmount SF 数量
     * @return usdtAmount 返回的 USDT 数量
     */
    function exchangeSFForUSDT(uint256 sfAmount) external override onlyStaking returns (uint256 usdtAmount) {
        // 1. 接收 SF
        SF.transferFrom(msg.sender, address(this), sfAmount);
        
        // 2. 基于当前价格计算 USDT 数量
        usdtAmount = calculateUSDTAmount(sfAmount);
        
        // 3. 检查 USDT 储备是否充足
        require(USDT.balanceOf(address(this)) >= usdtAmount + minUSDTReserve, "Insufficient USDT reserve");
        
        // 4. 转出 USDT
        USDT.transfer(msg.sender, usdtAmount);
        
        emit ExchangeSFForUSDT(msg.sender, sfAmount, usdtAmount);
    }
    
    /**
     * @dev 白名单充值（链下购买后转入）
     */
    function depositFromWhitelist(uint256 sfAmount, uint256 usdtAmount) external override onlyOwner {
        if (sfAmount > 0) {
            SF.transferFrom(msg.sender, address(this), sfAmount);
        }
        if (usdtAmount > 0) {
            USDT.transferFrom(msg.sender, address(this), usdtAmount);
        }
        emit WhitelistDeposit(msg.sender, sfAmount, usdtAmount);
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
        minSFReserve = _minSFReserve;
        minUSDTReserve = _minUSDTReserve;
        emit ReserveThresholdUpdated(_minSFReserve, _minUSDTReserve);
    }
    
    /**
     * @dev 紧急提取（仅 owner）
     */
    function emergencyWithdraw(address token, uint256 amount, address to) external override onlyOwner {
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
        address _stakingContract
    ) {
        _minSFReserve = minSFReserve;
        _minUSDTReserve = minUSDTReserve;
        _stakingContract = stakingContract;
    }
}
