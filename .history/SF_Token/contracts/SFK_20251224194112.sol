// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.8.25;

import {FirstLaunch} from "./abstract/FirstLaunch.sol";
import {Owned} from "solmate/src/auth/Owned.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {ExcludedFromFeeList} from "./abstract/ExcludedFromFeeList.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Helper} from "./lib/Helper.sol";
import {BaseDEX} from "./abstract/dex/BaseDEX.sol";
import {_USDT, _SF, FUND_ADDRESS} from "./Const.sol";
import {IReferral} from "./interface/IReferral.sol";
import {IStaking} from "./interface/IStaking.sol";
import {ITWAPOracle} from "./interface/ITWAPOracle.sol";

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


    // 记录扣税的SFK的数量
    uint256 public totalAmountLPFeeUSDT;
    uint256 public totalAmountNodeFee;
    uint256 public totalAmountTechFee;

    uint256 public totalAmountLPFeeSF;


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
