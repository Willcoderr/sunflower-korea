// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MockERC20.sol";

contract MockSFK is MockERC20 {
    uint112 private reserveUSDT;
    uint112 private reserveSF;

    constructor() MockERC20("Mock SFK", "SFK") {}

    function setReserves(uint112 usdtReserve, uint112 sfReserve) external {
        reserveUSDT = usdtReserve;
        reserveSF = sfReserve;
    }

    function getReserveUSDT() external view returns (uint112) {
        return reserveUSDT;
    }

    function getReserveSF() external view returns (uint112) {
        return reserveSF;
    }
}
