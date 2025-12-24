// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Owned} from "solmate/src/auth/Owned.sol";
import {IStaking} from "./interface/IStaking.sol";

/**
 * @title StakingReward
 * @dev 处理质押奖励分配、直推关系、团队等级等功能
 * 从 Staking 合约中提取出来，以解决合约代码大小超限问题
 */
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
            // bool isNewUser = !_isInDirectReferralList(parent, user);
            // if (isNewUser) {
            //     directReferralList[parent].push(user);
            //     directReferralCount[parent] += 1;
            // }
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
                // 新用户成为直推，如果新用户未解锁，不需要更新计数器
                if (nowUnlocked) {
                    // 新用户且已解锁，父级计数器+1
                    qualifiedDirectReferralCount[parent]++;
                }
            } else {
                // 已存在的用户，检查状态变化
                if (!wasUnlocked && nowUnlocked) {
                    // 从锁定变为解锁：计数器+1
                    qualifiedDirectReferralCount[parent]++;
                } else if (wasUnlocked && !nowUnlocked) {
                    // 从解锁变为锁定：计数器-1
                    // 质押时理论上不会发生这种情况，但为安全起见保留
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
            // 解质押时，只可能发生：true->true 或 true->false
            // 理论上不会发生 false->true（解质押不会增加余额）
            if (wasUnlocked && !nowUnlocked) {
                // 从解锁变为锁定：计数器-1
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

            // address[] memory directRefs = getDirectReferrals(referral);
            // uint256 qualifiedDirectCount = 0;
            // for (uint256 j = 0; j < directRefs.length; j++) {
            //     if (isUnlocked[directRefs[j]]) {
            //         qualifiedDirectCount++;
            //         if(qualifiedDirectCount >= generation){
            //             break;
            //         }
            //     }
            // }
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

    // 处理团队收益分配, 需要级差处理。
    function newTeamReward(
        address _user,
        uint256 profitReward
    ) public returns (uint256 distributed) {
        uint256 dynamicRewardPool = (profitReward * 30) / 100;
        uint256 totalTeamReward = (dynamicRewardPool * 18) / 100;

        address currentUser = _getReferral(_user);
        uint256 maxDepth = 30;
        uint256 depth = 0;
        uint256 distributedLevel = 0; // 已分配的最高等级（0-18）

        // 从下往上遍历
        while (currentUser != address(0) && depth < maxDepth) {
            uint256 level = getTeamLevel(currentUser);

            // 计算等级对应的比例
            uint256 levelRate = 0;
            if (level == 1) levelRate = 3;
            else if (level == 2) levelRate = 6;
            else if (level == 3) levelRate = 9;
            else if (level == 4) levelRate = 12;
            else if (level == 5) levelRate = 15;
            else if (level == 6) levelRate = 18;

            // 如果当前上级等级比已分配的高，拿差额
            if (levelRate > distributedLevel) {
                uint256 diff = levelRate - distributedLevel;
                uint256 userReward = (totalTeamReward * diff) / 18;

                if (userReward > 0) {
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
                }

                // 如果已达到最高等级(18)，停止遍历
                if (distributedLevel >= 18) {
                    break;
                }
            }
            // 如果 levelRate <= distributedLevel，该上级拿 0（被平级）

            currentUser = _getReferral(currentUser);
            depth++;
        }

        // 如果没有分配完18%，剩余的转给基金
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
        // uint256[] memory dept1Levels,
        // uint256[] memory dept2Levels
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

            // departmentLevel[users[i]][0] = dept1Levels[i];
            // departmentLevel[users[i]][1] = dept2Levels[i];

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
