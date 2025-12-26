// Sources flattened with hardhat v2.27.1 https://hardhat.org

// SPDX-License-Identifier: AGPL-3.0-only AND MIT AND UNLICENSED

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.8.20 <0.8.25;

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


// File contracts/interface/IStaking.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

/**
 * @title IStaking Interface
 * @dev Staking 合约接口，用于 StakingReward 合约调用 Staking 合约的函数
 */
interface IStaking {
    /**
     * @dev 获取用户的推荐人地址
     * @param _address 用户地址
     * @return 推荐人地址
     */
    function getReferral(address _address) external view returns(address);
    
    /**
     * @dev 检查用户是否已绑定推荐人
     * @param _address 用户地址
     * @return 是否已绑定
     */
    function isBindReferral(address _address) external view returns(bool);
    
    /**
     * @dev 获取用户余额（mapping 的自动 getter）
     * @param 用户地址
     * @return 余额
     */
    function balances(address) external view returns(uint256);
    
    /**
     * @dev 获取团队总投资价值（mapping 的自动 getter）
     * @param 用户地址
     * @return 团队总投资价值
     */
    function teamTotalInvestValue(address) external view returns(uint256);
    
    /**
     * @dev 获取团队虚拟投资价值（mapping 的自动 getter）
     * @param 用户地址
     * @return 团队虚拟投资价值
     */
    function teamVirtuallyInvestValue(address) external view returns(uint256);
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


// File contracts/StakingReward.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;




contract StakingReward is Owned {
    // 关联的 Staking 合约
    IStaking public stakingContract;

    // 代币地址
    IERC20 public USDT;
    address public profitAddress;
    address public fundAddress;

    // 用户是否解锁成为推荐人
    mapping(address => bool) public isUnlocked;


    // 直推关系相关
    mapping(address => uint256) public directReferralCount;
    mapping(address => uint256) public directReferralPerformance;
    mapping(address => address[]) private directReferralList;
    mapping(address => mapping(address => bool)) private isDirectReferral;
    mapping(address => uint256) public qualifiedDirectReferralCount;

    // 团队等级相关
    mapping(address => uint256) public teamLevel;
    mapping(address => uint256) public lastRewardTime;
    mapping(address => mapping(uint256 => uint256)) public departmentLevel;

    // 部门统计
    mapping(address => uint256) public level3DeptCount;
    mapping(address => uint256) public level4DeptCount;
    mapping(address => uint256) public level5DeptCount;
    mapping(address => mapping(address => uint256)) public departmentVolume;
    mapping(address => mapping(address => uint256)) public departmentLevelMap;

    // 收益累计
    mapping(address => uint256) public newReferralProfitSum;
    mapping(address => uint256) public newTeamProfitSum;

    // 已分配记录（避免重复分配）
    mapping(address => mapping(address => uint256))
        private claimedReferralRewardByUser;
    mapping(address => mapping(address => uint256))
        private claimedTeamRewardByUser;

    // 事件
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
    event StakePerformanceUpdate(
        address indexed user,
        address indexed parent,
        uint256 amount,
        uint40 timestamp,
        uint256 blockNumber
    );
    event UnstakePerformanceUpdate(
        address indexed user,
        address indexed parent,
        uint256 amount,
        uint40 timestamp,
        uint256 blockNumber
    );

    event BatchLevelUpdate(address[] users, uint256[] levels, uint40 timestamp);

    // 接口定义（通过接口直接调用 Staking 合约）
    function _getReferral(address user) private view returns (address) {
        return stakingContract.getReferral(user);
    }

    function _isBindReferral(address user) private view returns (bool) {
        return stakingContract.isBindReferral(user);
    }

    function _getBalance(address user) private view returns (uint256) {
        return stakingContract.balances(user);
    }

    function _getTeamTotalInvestValue(
        address user
    ) private view returns (uint256) {
        return stakingContract.teamTotalInvestValue(user);
    }

    function _getTeamVirtuallyInvestValue(
        address user
    ) private view returns (uint256) {
        return stakingContract.teamVirtuallyInvestValue(user);
    }

    modifier onlyStaking() {
        require(msg.sender == address(stakingContract), "Only Staking");
        _;
    }

    constructor(
        address _usdt,
        address _profitAddress,
        address _fundAddress
    ) Owned(msg.sender) {
        USDT = IERC20(_usdt);
        profitAddress = _profitAddress;
        fundAddress = _fundAddress;
    }

    function setStakingContract(address _staking) external onlyOwner {
        require(_staking != address(0), "Invalid address");
        stakingContract = IStaking(_staking);
    }

    // ============ 直推关系维护 ============
    function getQualifiedDirectReferralCount(
        address user
    ) public view returns (uint256) {
        return qualifiedDirectReferralCount[user];
    }
    
    function updateDirectReferralData(
        address user,
        uint256 amount
    ) external onlyStaking {
        address parent = _getReferral(user);
        if (parent != address(0)) {

            bool wasUnlocked = isUnlocked[user];  // 记录旧状态
            bool  isNewUser = !isDirectReferral[parent][user];

            if(isNewUser){
                directReferralList[parent].push(user);
                directReferralCount[parent] += 1;
                isDirectReferral[parent][user] = true;
            }
            directReferralPerformance[parent] += amount;

            uint256 newBalance = _getBalance(user);
            bool nowUnlocked = newBalance >= 200e18;
            if (isNewUser) {
                if (nowUnlocked) {
                    qualifiedDirectReferralCount[parent]++;
                }
            } else {
                if (!wasUnlocked && nowUnlocked) {
                    qualifiedDirectReferralCount[parent]++;
                } else if (wasUnlocked && !nowUnlocked) {
                    if (qualifiedDirectReferralCount[parent] > 0) {
                        qualifiedDirectReferralCount[parent]--;
                    }
                }
            }

            isUnlocked[user] = nowUnlocked;

            // 发出事件，记录直推关系更新
            emit StakePerformanceUpdate(
                user,
                parent,
                amount,
                uint40(block.timestamp),
                block.number
            );
        }
    }


    // 解压发出事件
    function emitUnstakePerformanceUpdate(address user,uint256 amount) external onlyStaking {
        address parent = _getReferral(user);
        if(parent !=  address(0)){
            bool wasUnlocked = isUnlocked[user];  // 记录旧状态

            uint256 newBalance = _getBalance(user);
            bool nowUnlocked = newBalance >= 200e18;
            if (wasUnlocked && !nowUnlocked) {
                if (qualifiedDirectReferralCount[parent] > 0) {
                    qualifiedDirectReferralCount[parent]--;
                }
            }
            isUnlocked[user] = nowUnlocked;
            emit UnstakePerformanceUpdate(
                user,
                parent,
                amount,
                uint40(block.timestamp),
                block.number
            );
        }
    }


    function getDirectReferrals(
        address user
    ) public view returns (address[] memory) {
        return directReferralList[user];
    }

    function getDirectReferralCount(
        address user
    ) public view returns (uint256) {
        uint256 count = directReferralCount[user];
        return count > 10 ? 10 : count;
    }

    function isUnlockedReferralReward(address user) public view returns (bool) {
        return _getBalance(user) >= 200e18;
    }

    // ============ 团队等级计算 ============

    function getTeamKpi(address user) public view returns (uint256) {
        return
            _getTeamTotalInvestValue(user) + _getTeamVirtuallyInvestValue(user);
    }

    function getTeamLevel(address user) public view returns (uint256) {
        return teamLevel[user];
    }

    struct UpdateLevelVars {
        uint256 maxKpi1;
        uint256 maxKpi2;
        address maxAddr1;
        address maxAddr2;
        uint256 maxLevel1;
        uint256 maxLevel2;
        uint256 count3;
        uint256 count4;
        uint256 count5;
    }

    // ============ 奖励分配 ============

    function newReferralReward(
        address _user,
        uint256 profitReward
    ) public returns (uint256 distributed) {
        uint256 dynamicRewardPool = (profitReward * 30) / 100;
        distributed = 0;
        uint256 totalReferralReward = (dynamicRewardPool * 10) / 100;
        uint256 perGenerationReward = dynamicRewardPool / 100;

        address[] memory referrals = _getReferrals(_user, 10);

        for (uint256 i = 0; i < referrals.length && i < 10; i++) {
            address referral = referrals[i];
            uint256 generation = i + 1;
            // 使用计数器替代数组遍历
            uint256 qualifiedDirectCount = qualifiedDirectReferralCount[referral];

            if (qualifiedDirectCount >= generation) {
                if (isUnlocked[referral]) {
                    uint256 generationReward = perGenerationReward;
                    uint256 taxAmount = (generationReward * 5) / 100;
                    uint256 afterTax = generationReward - taxAmount;

                    newReferralProfitSum[referral] += generationReward;
                    distributed += generationReward;
                    claimedReferralRewardByUser[referral][
                        _user
                    ] += generationReward;
                    emit NewReferralReward(
                        _user,
                        referral,
                        afterTax,
                        generation,
                        uint40(block.timestamp)
                    );

                    USDT.transfer(referral, afterTax);
                    USDT.transfer(profitAddress, taxAmount);
                } else {
                    distributed += perGenerationReward;
                    USDT.transfer(fundAddress, perGenerationReward);
                }
            }
        }

        uint256 remainingReward = totalReferralReward - distributed;
        if (remainingReward > 0) {
            USDT.transfer(fundAddress, remainingReward);
            distributed += remainingReward;
        }

        return distributed;
    }

    function newTeamReward(
        address _user,
        uint256 profitReward
    ) public returns (uint256 distributed) {
        uint256 dynamicRewardPool = (profitReward * 30) / 100;
        uint256 totalTeamReward = (dynamicRewardPool * 18) / 100;

        address currentUser = _getReferral(_user);
        uint256 maxDepth = 30;
        uint256 depth = 0;
        uint256 distributedLevel = 0;

        while (currentUser != address(0) && depth < maxDepth) {
            uint256 level = getTeamLevel(currentUser);

            uint256 levelRate = level > 0 && level <= 6 ? level * 3 : 0;
            if (levelRate <= distributedLevel) {
                currentUser = _getReferral(currentUser);
                depth++;
                continue;
            }
            // 计算差额奖励
            uint256 diff = levelRate - distributedLevel;
            uint256 userReward = (totalTeamReward * diff) / 18;

            // 如果奖励为0，跳过（减少嵌套）
            if (userReward == 0) {
                currentUser = _getReferral(currentUser);
                depth++;
                continue;
            }

            // 分配奖励
            uint256 taxAmount = (userReward * 5) / 100;
            uint256 afterTax = userReward - taxAmount;

            newTeamProfitSum[currentUser] += userReward;
            distributed += userReward;
            claimedTeamRewardByUser[currentUser][_user] += userReward;
            
            emit NewTeamReward(
                currentUser,
                level,
                afterTax,
                uint40(block.timestamp)
            );

            USDT.transfer(currentUser, afterTax);
            USDT.transfer(profitAddress, taxAmount);

            // 更新已分配等级
            distributedLevel = levelRate;

            if (distributedLevel >= 18) {
                break;
            }

            currentUser = _getReferral(currentUser);
            depth++;
        }
        if (distributedLevel < 18) {
            uint256 remainingRate = 18 - distributedLevel;
            uint256 remainingReward = (totalTeamReward * remainingRate) / 18;
            if (remainingReward > 0) {
                USDT.transfer(fundAddress, remainingReward);
                distributed += remainingReward;
            }
        }

        return distributed;
    }

    function newDistributionLogic(
        address _user,
        uint256 profitReward
    ) external onlyStaking returns (uint256 totalDistributed) {
        if (profitReward == 0) return 0;

        uint256 lastTime = lastRewardTime[_user];
        if (lastTime == 0) {
            lastRewardTime[_user] = block.timestamp;
            return 0;
        }

        if (block.timestamp < lastTime + 1 days) {
            return 0;
        }

        uint256 distributed = 0;
        distributed += newReferralReward(_user, profitReward);
        distributed += newTeamReward(_user, profitReward);
        lastRewardTime[_user] = block.timestamp;

        return distributed;
    }

    function _getReferrals(
        address _address,
        uint256 _num
    ) private view returns (address[] memory) {
        address[] memory ups = new address[](_num);
        address cur = _getReferral(_address);
        uint256 i = 0;
        while (cur != address(0) && i < _num) {
            ups[i] = cur;
            unchecked {
                i++;
            }
            cur = _getReferral(cur);
        }
        if (i < _num) {
            assembly {
                mstore(ups, i)
            }
        }
        return ups;
    }

    // ============ 查询函数 ============

    function getNewDistributionInfo(
        address user
    )
        external
        view
        returns (
            uint256 referralProfit,
            uint256 teamProfit,
            uint256 teamLevelValue,
            uint256 directCount,
            bool canClaimReward
        )
    {
        referralProfit = newReferralProfitSum[user];
        teamProfit = newTeamProfitSum[user];
        teamLevelValue = getTeamLevel(user);
        directCount = getDirectReferralCount(user);
        canClaimReward = (lastRewardTime[user] == 0 ||
            block.timestamp >= lastRewardTime[user] + 1 days);
    }

    function getDepartmentStats(
        address user
    )
        external
        view
        returns (
            uint256 count3,
            uint256 count4,
            uint256 count5,
            uint256 dept1Level,
            uint256 dept2Level,
            uint256 teamKpi
        )
    {
        count3 = level3DeptCount[user];
        count4 = level4DeptCount[user];
        count5 = level5DeptCount[user];
        dept1Level = departmentLevel[user][0];
        dept2Level = departmentLevel[user][1];
        teamKpi = getTeamKpi(user);
    }

    // ============ Owner 函数 ============

    function batchUpdateTeamLevels(
        address[] memory users,
        uint256[] memory levels,
        uint256[] memory count3s,
        uint256[] memory count4s,
        uint256[] memory count5s
    ) external onlyOwner {
        require(
            users.length == levels.length &&
             users.length == count3s.length &&
        users.length == count4s.length &&
        users.length == count5s.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < users.length; i++) {

            uint256 previousLevel = teamLevel[users[i]];
            uint256 newLevel = levels[i];
            
            teamLevel[users[i]] = newLevel;

            level3DeptCount[users[i]] = count3s[i];
            level4DeptCount[users[i]] = count4s[i];
            level5DeptCount[users[i]] = count5s[i];

            if(previousLevel != newLevel){
                uint256 kpi = getTeamKpi(users[i]);
                emit TeamLevelUpdated(users[i], previousLevel, newLevel, kpi, uint40(block.timestamp));
            }
        }
        emit BatchLevelUpdate(users, levels, uint40(block.timestamp));
    }

    function updateUserLevel(
        address user,
        uint256 level,
        uint256 dept1Level,
        uint256 dept2Level
    ) external onlyOwner {
        teamLevel[user] = level;
        departmentLevel[user][0] = dept1Level;
        departmentLevel[user][1] = dept2Level;
    }
}
