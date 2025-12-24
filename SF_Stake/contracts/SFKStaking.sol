/**
 *Submitted for verification at BscScan.com on 2025-10-11
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {Owned} from "solmate/src/auth/Owned.sol";
import {ISFErc20} from "./interface/ISF.sol";
import {ISFK} from "./interface/ISFK.sol";
import {ISFExchange} from "./interface/ISFExchange.sol";
import {IStakingReward} from "./interface/IStakingReward.sol";
import {_USDT, _ROUTER} from "./Const.sol";

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

        // 检测是否形成循环
        require(!_wouldCreateCycle(_user, _referral), "CYCLE_DETECTED");

        _parentOf[_user] = _referral;
        _isBound[_user] = true;
        _allUsers.push(_user);
        unchecked { _directCount[_referral] += 1; }

        emit BindReferral(_user, _referral);
    }

    function _wouldCreateCycle(address newUser, address parent) private view returns (bool) {
        address current = parent;
        uint256 depth = 0;
        uint256 maxDepth = 100; // 设置合理的最大深度
        
        while (current != address(0) && depth < maxDepth) {
            if (current == newUser) {
                return true;
            }
            current = _parentOf[current];
            depth++;
        }
        return false;
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
    

    // ============ 原正式配置（已注释）============
    // 收益率配置：1天期每天0.3%，15天期每天0.6%，30天期每天1.3%
    // 每秒复利因子计算：(1 + 日收益率)^(1/86400)
    // uint256[3] rates = [1000000003463000000,1000000006917000000,1000000014950000000];
    // uint256[3] stakeDays = [1 days, 15 days, 30 days];
    // uint40 public constant timeStep = 1 days;
    
    // ============ 测试模式配置 ============
    // 测试模式：时间段改为1分钟、15分钟、30分钟
    // 收益率配置保持不变（使用相同的复利因子）
    uint256[3] rates = [1000000003463000000,1000000006917000000,1000000014950000000];
    uint256[3] stakeDays = [1 minutes, 15 minutes, 30 minutes];
    uint40 public constant timeStep = 1 minutes;

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

    // 审计建议：decimals 和 totalSupply 可以考虑从 OpenZeppelin 导入（建议性更新）
 
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

    uint8 constant maxD = 30;

    RecordTT[] public t_supply;
    uint256 public mMinSwapRatioUsdt = 50;//100
    uint256 public mMinSwapRatioToken = 50;//100
    uint256 startTime=0;
    // uint256 constant network1InTime=90 days;  // 原正式配置
    uint256 constant network1InTime=90 minutes;  // 测试模式：改为90分钟
    bool bStart = false;
    
    // 优化：使用10秒时间桶记录质押量，实现精确的滑动窗口查询
    // 10秒桶索引计算：bucketIndex = block.timestamp / 10 seconds
    mapping(uint256 => uint256) public tenSecondStakeAmount;  // bucketIndex => 该10秒的累计质押量
    uint256 public lastUpdatedBucket;  // 最后更新的10秒桶索引

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

        // SFErc20 = ISFErc20(0x8b07a652203905240a3b9759627f17d6e8f14994);
        // SFErc20.approve(address(ROUTER), type(uint256).max);

        // ISFK = ISFK(address(0x8b07a652203905240a3b9759627f17d6e8F14994));
        // ISFK.approve(address(ROUTER), type(uint256).max);
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
    
    /**
     * @dev 获取最近1分钟的质押量（滑动窗口：block.timestamp - 1 minutes 到 block.timestamp）
     * 使用10秒时间桶，实现精确的滑动窗口查询，O(6)复杂度
     */
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
        
        // 如果10秒桶中没有数据（合约刚部署或该时间段没有质押），使用旧方法作为fallback
        // 这种情况应该很少发生? 是否还需要 这个fallback
        if (value == 0 && t_supply.length > 0) {
            uint256 len = t_supply.length;
            uint256 last_supply = totalSupply;
            
            // 限制最多遍历最近100条记录，防止gas超限
            uint256 maxIterations = len > 100 ? len - 100 : 0;
            
            for (uint256 i = len - 1; i >= maxIterations; i--) {
                RecordTT storage stake_tt = t_supply[i];
                if (windowStart > stake_tt.stakeTime) {
                    break;
                } else {
                    last_supply = stake_tt.tamount;
                }
                if (i == 0) break;
            }
            
            if(totalSupply > last_supply){
                value = totalSupply-last_supply;
            }
        }
        
        return value;
    }
    function canStakeAmount() public view returns (uint256) {
        uint256 amout0=0;
        if(startTime==0) return amout0;
        if(block.timestamp < startTime) return amout0;
        // uint256 num00 = (block.timestamp - startTime)/(timeStep);
        // amout0 = 100 ether + num00 * (30 ether );

        // 计算经过了多少个24小时
        uint256 daysElapsed = (block.timestamp - startTime) / 1 days;
        
        // 初始200U，每24小时递增100U
        amout0 = 200 ether + daysElapsed * (100 ether);

        if(amout0 > 2000 ether) amout0 = 2000 ether;
        return amout0;
    }
    // function maxStakeAmount() public view returns (uint256) {
    //     uint256 lastIn = network1In();
    //     uint256 canStakV = canStakeAmount();
    //     if(lastIn>canStakV) return 0;
    //     lastIn=canStakV - lastIn;
    //     uint112 reverseu = SFK.getReserveUSDT();
    //     uint256 p1 = reverseu / 100;
    //     if (lastIn > p1) lastIn = p1;
    //     return lastIn;
    // }
    function maxStakeAmount() public view returns (uint256) {
        uint256 lastIn = network1In();  // 最近1分钟的入场量
        uint256 canStakV = canStakeAmount();  // 每分钟可入场额度
        
        // 如果最近1分钟入场量超过额度，返回0
        if(lastIn > canStakV) return 0;
        
        // 计算剩余可入场额度
        uint256 remaining = canStakV - lastIn;
        
        // 获取底池USDT储备
        uint112 reverseu = SFK.getReserveUSDT();
        
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
    // 审计合约 SF-44 提取函数公共部分
    // 内部函数：计算单个质押记录的详细信息
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
        
        // 检查用户是否已绑定推荐关系（必须绑定才能质押）
        require(isBindReferral(user), "Must bind referral");
        // 添加流动性
        swapAndAddLiquidity(_amount);
        // 铸造NFT
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
            
    /**
     * 流程：
     * 1. USDT/SFK 池（500 USDT）：250 USDT 换 SFK + 250 USDT 添加流动性
     * 2. SF/SFK 池（500 USDT）：
     *    - 500 USDT 通过 sfExchange 换取 SF（无税）
     *    - 50% SF 换 SFK + 50% SF 添加流动性到 SF/SFK 池
     */
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
        // 计算剩余的 50% USDT（500U）价值多少 SF
        // uint256 requiredSF = calculateRequiredSF(halfAmount);
        
        // // 检查合约中是否有足够的 SF
        // require(SF.balanceOf(address(this)) >= requiredSF, "Insufficient SF in contract");

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
        
        // // ============ 第三部分：将剩余的 500U 转给 EOA 地址 ============
        // // 直接将剩余的 50% USDT（500U）转给 EOA 地址（gas费由调用stake的用户支付）
        // if (eoaWithdrawAddress != address(0)) {
        //     USDT.transfer(eoaWithdrawAddress, halfAmount);
        // }
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
        // if(endTime>user_record.oriStakeTime+30*timeStep) 
        //     endTime=user_record.oriStakeTime+30*timeStep;
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
        // stake_period = stake_period > 30*timeStep ? 30*timeStep : stake_period;

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
            
            // 如果得到的 USDT 仍然不足，是否用合约余额补充，待定
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

    // 取消单独提取收益，只能在unstake中提取收益
    // // 提取收益逻辑 (逻辑不正确需要修改成 从SFK/USDT和SF/SFK池共同拿出一半的金额)
    // function rewardOnly(uint256 index) external onlyEOA nonReentrant returns (uint256) {
    //     Vars memory v;
    //     (v.reward, v.stake) = calReward(index);
    //     uint256 dvv = (v.reward - v.stake) * 30 / 100; 

    //     v.sfBefore   = SFK.balanceOf(address(this));
    //     v.usdtBefore  = USDT.balanceOf(address(this));

    //     // 计算期望得到的 USDT 数量（v.reward 和 v.stake 是 SFK 数量，需要转换成 USDT）
    //     // v.reward - v.stake + dvv 是收益部分（SFK 数量）
    //     uint256 expectedUsdt = getUsdtAmountsOut(v.reward - v.stake + dvv);
        
    //     // 计算需要多少 SF 才能得到期望的 USDT 数量
    //     address[] memory pathSF = new address[](2);
    //     pathSF[0] = address(SF);
    //     pathSF[1] = address(USDT);
    //     uint256[] memory amountsIn = ROUTER.getAmountsIn(expectedUsdt, pathSF);
    //     uint256 requiredSF = amountsIn[0];
        
    //     // 检查合约是否有足够的 SF
    //     require(v.sfBefore >= requiredSF, "Insufficient SF balance");
        
    //     uint256 maxSFInput = v.sfBefore > requiredSF * 110 / 100 
    //         ? requiredSF * 110 / 100  // 如果余额充足，使用 requiredSF + 10% 滑点
    //         : v.sfBefore;  // 如果余额有限，使用全部余额
        
    //     ROUTER.swapTokensForExactTokens(
    //         expectedUsdt,  // amountOut: 期望得到的 USDT 数量
    //         maxSFInput,    // amountInMax: 最多支付的 SF 数量
    //         pathSF,
    //         address(this),
    //         block.timestamp + 300
    //     );

    //     uint256 sfUsed = v.sfBefore - SF.balanceOf(address(this));
    //     uint256 usdtGot = USDT.balanceOf(address(this)) - v.usdtBefore;

    //     uint256 usdtForDev; 
    //     uint256 usdtForUser; 
    //     uint256 dvvUsdt = getUsdtAmountsOut(dvv);
    //     if (usdtGot > dvvUsdt) {
    //         usdtForDev  = dvvUsdt;
    //         usdtForUser = usdtGot - usdtForDev;
    //     } else {
    //         usdtForDev  = (usdtGot * 30) / 100;
    //         usdtForUser = usdtGot - usdtForDev;
    //     }

    //     // lastRewardTime 现在由 StakingReward 合约管理
        
    //     // 现在执行所有外部调用（Interactions）
    //     // 用户得到usdtForUser（70%收益），剩余的30%保留在合约中，由上级手动领取
    //     USDT.transfer(msg.sender, usdtForUser);
    //     SF.recycle(sfUsed);
    //     return v.reward - v.stake;
    // }

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

    // ============ 新分配逻辑函数 ============
    // 已移至 StakingReward 合约，通过 stakingReward 接口调用
    
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