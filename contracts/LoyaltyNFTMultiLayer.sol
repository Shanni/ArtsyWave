// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract MLM {
    address public owner;
    uint public totalInvested;
    uint public constant LEVELS = 5;
    uint[LEVELS] public levelPercents = [10, 5, 3, 2, 1];
    mapping(address => Investor) public investors;

    struct Investor {
        address referrer;
        uint invested;
        uint totalEarned;
        uint[LEVELS] earnedFromLevels;
    }

    constructor() {
        owner = msg.sender;
    }

    function invest(address referrer) public payable {
        require(msg.value > 0, "Investment amount must be greater than zero.");
        require(referrer != msg.sender, "Referrer cannot be self.");
        Investor storage investor = investors[msg.sender];
        require(investor.invested == 0, "Investor has already invested.");

        investor.referrer = referrer;
        investor.invested = msg.value;
        totalInvested += msg.value;

        distribute(referrer, msg.value);
    }

    function distribute(address referrer, uint amount) private {
        for (uint i = 0; i < LEVELS; i++) {
            if (referrer == address(0)) {
                break;
            }
            Investor storage investor = investors[referrer];
            uint levelPercent = levelPercents[i];
            uint levelReward = (amount * levelPercent) / 100;
            investor.earnedFromLevels[i] += levelReward;
            investor.totalEarned += levelReward;
            amount -= levelReward;
            referrer = investor.referrer;
        }
        owner.transfer(amount);
    }

    function withdraw() public {
        Investor storage investor = investors[msg.sender];
        uint totalEarned = investor.totalEarned;
        require(totalEarned > 0, "No earnings to withdraw.");
        investor.totalEarned = 0;
        payable(msg.sender).transfer(totalEarned);
    }
}
