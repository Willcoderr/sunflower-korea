// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MockERC20.sol";

contract MockSF is MockERC20 {
    address private pair;

    constructor() MockERC20("Mock SF", "SF") {}

    function setUniswapV2Pair(address pairAddress) external {
        pair = pairAddress;
    }

    function uniswapV2Pair() external view returns (address) {
        return pair;
    }
}
