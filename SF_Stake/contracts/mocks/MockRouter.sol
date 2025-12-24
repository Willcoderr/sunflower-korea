// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMintableERC20 {
    function mint(address to, uint256 amount) external returns (bool);
}

contract MockRouter {
    struct SwapRecord {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        address to;
    }

    struct LiquidityRecord {
        address tokenA;
        address tokenB;
        uint256 amountA;
        uint256 amountB;
        address to;
    }

    mapping(address => mapping(address => uint256)) public rates;
    SwapRecord public lastSwap;
    LiquidityRecord public lastLiquidity;
    uint256 public swapCount;
    uint256 public liquidityCount;
    mapping(uint256 => SwapRecord) public swapRecords;
    mapping(uint256 => LiquidityRecord) public liquidityRecords;

    function reset() external {
        swapCount = 0;
        liquidityCount = 0;
        lastSwap = SwapRecord(address(0), address(0), 0, 0, address(0));
        lastLiquidity = LiquidityRecord(address(0), address(0), 0, 0, address(0));
    }

    function setRate(address tokenIn, address tokenOut, uint256 rate) external {
        rates[tokenIn][tokenOut] = rate;
    }

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts) {
        require(path.length >= 2, "path");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i = 0; i < path.length - 1; i++) {
            uint256 rate = rates[path[i]][path[i + 1]];
            if (rate == 0) {
                rate = 1e18;
            }
            amounts[i + 1] = (amounts[i] * rate) / 1e18;
        }
    }

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts) {
        require(path.length >= 2, "path");
        amounts = new uint256[](path.length);
        amounts[path.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            uint256 rate = rates[path[i - 1]][path[i]];
            if (rate == 0) {
                rate = 1e18;
            }
            amounts[i - 1] = (amounts[i] * 1e18 + rate - 1) / rate;
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256,
        address[] calldata path,
        address to,
        uint256
    ) external {
        require(path.length >= 2, "path");
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        uint256 rate = rates[path[0]][path[1]];
        if (rate == 0) {
            rate = 1e18;
        }
        uint256 amountOut = (amountIn * rate) / 1e18;
        IMintableERC20(path[1]).mint(to, amountOut);
        lastSwap = SwapRecord(path[0], path[1], amountIn, amountOut, to);
        swapRecords[swapCount] = lastSwap;
        swapCount += 1;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256,
        uint256,
        address to,
        uint256
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        IERC20(tokenA).transferFrom(msg.sender, to, amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, to, amountBDesired);
        amountA = amountADesired;
        amountB = amountBDesired;
        liquidity = 0;
        lastLiquidity = LiquidityRecord(tokenA, tokenB, amountADesired, amountBDesired, to);
        liquidityRecords[liquidityCount] = lastLiquidity;
        liquidityCount += 1;
    }
}
