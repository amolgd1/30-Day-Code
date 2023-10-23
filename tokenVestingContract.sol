// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a token vesting contract,
// where tokens are gradually released over a period of time. ****////


pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract tokenVesting {
    IERC20 public token;
    address owner;

    // This mapping associates user addresses with their vesting periods in UNIX timestamps.
    mapping(address => uint256) public vestingPeriods;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    // This function allows users to vest tokens with a specified amount and vesting period.
    function tokenVest(uint256 amount, uint256 _vestingPeriodInMinutes) public {
        require(amount > 0, "Invalid amount");
        uint256 vestingPeriod = block.timestamp + (_vestingPeriodInMinutes * 1 minutes);
        vestingPeriods[msg.sender] = vestingPeriod;

        // Transfer tokens from the user to this contract.
        token.transferFrom(msg.sender, address(this), amount);
    }

    // This function allows users to remove vested tokens after the vesting period has ended.
    function removeVesting(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        uint256 userVestingPeriod = vestingPeriods[msg.sender];
        require(userVestingPeriod > 0, "No vesting period set for this user");
        require(block.timestamp >= userVestingPeriod, "Vesting period not ended yet");

        // Transfer vested tokens back to the user.
        token.transfer(msg.sender, amount);
    }
}
