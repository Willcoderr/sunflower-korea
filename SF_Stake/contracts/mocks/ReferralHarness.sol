// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../SFKStaking.sol";

contract ReferralHarness is Referral {
    function bindReferralExternal(address parent, address user) external {
        bindReferral(parent, user);
    }
}
