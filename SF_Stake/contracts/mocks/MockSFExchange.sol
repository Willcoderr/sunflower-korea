// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMintableERC20 {
    function mint(address to, uint256 amount) external returns (bool);
}

contract MockSFExchange {
    IERC20 public usdt;
    IMintableERC20 public sf;

    uint256 public rate = 1e18;
    bool public shouldRevert;

    uint256 public reserveSF;
    uint256 public reserveUSDT;
    bool public sfSufficient = true;
    bool public usdtSufficient = true;

    constructor(address usdtAddress, address sfAddress) {
        usdt = IERC20(usdtAddress);
        sf = IMintableERC20(sfAddress);
    }

    function setRate(uint256 newRate) external {
        rate = newRate;
    }

    function setShouldRevert(bool value) external {
        shouldRevert = value;
    }

    function setReserveStatus(uint256 sfBalance, uint256 usdtBalance, bool sfOk, bool usdtOk) external {
        reserveSF = sfBalance;
        reserveUSDT = usdtBalance;
        sfSufficient = sfOk;
        usdtSufficient = usdtOk;
    }

    function exchangeUSDTForSF(uint256 usdtAmount) external returns (uint256 sfAmount) {
        usdt.transferFrom(msg.sender, address(this), usdtAmount);
        sfAmount = (usdtAmount * rate) / 1e18;
        sf.mint(msg.sender, sfAmount);
    }

    function exchangeSFForUSDT(uint256 sfAmount) external returns (uint256 usdtAmount) {
        if (shouldRevert) {
            revert("Mock exchange revert");
        }
        IERC20(address(sf)).transferFrom(msg.sender, address(this), sfAmount);
        usdtAmount = (sfAmount * rate) / 1e18;
        IMintableERC20(address(usdt)).mint(msg.sender, usdtAmount);
    }

    function getReserveStatus() external view returns (
        uint256 sfBalance,
        uint256 usdtBalance,
        bool sfOk,
        bool usdtOk
    ) {
        return (reserveSF, reserveUSDT, sfSufficient, usdtSufficient);
    }
}
