// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStakeLike {
    function stake(uint160 amount, uint8 stakeIndex) external;
}

contract MockStakeCaller {
    function callStake(address staking, uint160 amount, uint8 stakeIndex) external {
        IStakeLike(staking).stake(amount, stakeIndex);
    }
}
