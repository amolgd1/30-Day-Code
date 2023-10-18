// SPDX-License-Identifier: MIT


//// **** Write a Solidity function to implement a staking system, 
// where users can earn rewards for holding tokens.  ****////

//add*
//function stake
//function unstake
//function claimReward
//function updateReward

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";  // Importing the ERC20 interface
import "@openzeppelin/contracts/access/Ownable.sol";     // Importing the Ownable contract from OpenZeppelin

contract StakingContract is Ownable {  // Defining the main contract, inheriting from Ownable
    IERC20 public token;  // The token used for staking and rewards
    uint256 public totalStaked;  // Total amount of tokens staked in the contract
    uint256 public totalRewards;  // Total rewards accumulated in the contract
    uint256 public stakingStartTime;  // Start time for staking
    uint256 public stakingEndTime;    // End time for staking
    uint256 public rewardRate;        // The rate at which rewards are distributed per minute
    mapping(address => uint256) public stakedBalances;  // Track staked balances for each user
    mapping(address => uint256) public rewards;         // Track rewards for each user

    event Staked(address indexed user, uint256 amount);  // Event emitted when a user stakes tokens
    event Unstaked(address indexed user, uint256 amount);  // Event emitted when a user unstakes tokens
    event RewardClaimed(address indexed user, uint256 amount);  // Event emitted when a user claims rewards

    constructor(address _token, uint256 _stakingDurationInMinutes, uint256 _initialReward, address _initialOwner) Ownable(_initialOwner) {
        // Constructor to initialize the contract with initial values
        token = IERC20(_token);  // Set the token used for staking and rewards
        stakingStartTime = block.timestamp;  // Record the current block timestamp as the start time
        stakingEndTime = block.timestamp + (_stakingDurationInMinutes * 1 minutes);  // Calculate and set the staking end time
        rewardRate = _initialReward / _stakingDurationInMinutes;  // Calculate the initial reward rate
        transferOwnership(_initialOwner);  // Transfer ownership of the contract to the specified initial owner
    }

    modifier stakingOpen() {
        // Modifier to check if staking is open
        require(
            block.timestamp >= stakingStartTime && block.timestamp <= stakingEndTime,
            "Staking is closed"
        );
        _;
    }

    modifier stakingClosed() {
        // Modifier to check if staking is closed
        require(block.timestamp > stakingEndTime, "Staking is still open");
        _;
    }

    function stake(uint256 amount) external stakingOpen {
        // Function for users to stake tokens
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        stakedBalances[msg.sender] += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake() external stakingOpen {
        // Function for users to unstake tokens
        uint256 amount = stakedBalances[msg.sender];
        require(amount > 0, "No tokens staked");
        stakedBalances[msg.sender] = 0;
        totalStaked -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external stakingClosed {
        // Function for users to claim rewards
        require(rewards[msg.sender] > 0, "No rewards to claim");
        uint256 amount = rewards[msg.sender];
        rewards[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit RewardClaimed(msg.sender, amount);
    }

    function updateReward() external stakingOpen {
        // Function to update rewards
        uint256 elapsedTime = block.timestamp - stakingStartTime;
        if (elapsedTime > 0) {
            uint256 newReward = (elapsedTime * rewardRate) - totalRewards;
            totalRewards += newReward;
            rewardRate = newReward / (stakingEndTime - stakingStartTime);
        }
    }
}
