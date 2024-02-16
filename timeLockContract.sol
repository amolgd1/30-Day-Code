// SPDX-License-Identifier: MIT

///// **** Write a Solidity function to implement a time-locked contract,
//  which allows funds to be withdrawn only after a certain time has elapsed. ****/////

pragma solidity 0.8.19;

contract TimeLock {
    struct Deposit {
        uint256 unlockTime;
        uint256 amount;
    }

    mapping(address => Deposit) private deposits;

    modifier AfterUnlockTime() {
        require(
            afterUnlockTime(),
            "Funds cannot be withdrawn before the unlock time"
        );
        _;
    }

    function afterUnlockTime() internal view returns (bool) {
        uint256 unlockTime = deposits[msg.sender].unlockTime;
        return block.timestamp >= unlockTime;
    }

    function deposit(uint256 _unlockTimeInMinutes) external payable {
        uint256 unlockTime = block.timestamp +
            (_unlockTimeInMinutes * 1 minutes);
        require(msg.value != 0, "deposit failed, must amount != 0");
        require(
            unlockTime > deposits[msg.sender].unlockTime,
            "New unlock time must be greater than the original unlock time"
        );

        deposits[msg.sender].unlockTime = unlockTime;
        deposits[msg.sender].amount = msg.value;
    }

    function setUnlockTime(uint256 _newUnlockTimeInMinutes) external {
        uint256 newUnlockTime = block.timestamp +
            (_newUnlockTimeInMinutes * 1 minutes);
        require(
            newUnlockTime > deposits[msg.sender].unlockTime,
            "unlock time must be greater than last unlock time"
        );

        deposits[msg.sender].unlockTime = newUnlockTime;
    }

    function withdraw() public payable AfterUnlockTime {
        require(
            deposits[msg.sender].amount >= msg.value,
            "you dnt have funds to withdraw"
        );

        deposits[msg.sender].unlockTime = 0;
        deposits[msg.sender].amount -= msg.value;

        (bool success, ) = payable(msg.sender).call{value: msg.value}("");
        require(success, "withdraw failed");
    }
}