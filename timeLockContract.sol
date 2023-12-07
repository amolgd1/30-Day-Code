// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a time-locked contract,
//  which allows funds to be withdrawn only after a certain time has elapsed. ****////

pragma solidity >0.5.0 <0.9.0;

contract timeLock {
    uint256 public unlocktime; // Timestamp when funds can be unlocked

    mapping(address=>uint) public balanceOf;

    constructor(uint256 unlocktimeMinutes) {
        unlocktime = block.timestamp + (unlocktimeMinutes * 1 minutes); // Calculate the unlock time
    }

    // Modifier to restrict a function to be callable only after the unlock time
    modifier Afterunlocktime() {
        require(
            block.timestamp >= unlocktime,
            "Funds cannot be withdrawn before the unlock time"
        );
        _;
    }

    // Function to allow deposits to the contract (can receive Ether)
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function setNewUnlocktime(uint _newUnlocktimeInMinutes) public {
        uint newUnlockTimestamp = block.timestamp + (_newUnlocktimeInMinutes * 1 minutes);
        require(newUnlockTimestamp > unlocktime,"Unlocktime must begreater than last unlock time");
        unlocktime = newUnlockTimestamp;
    }

    // Function to withdraw funds from the contract, restricted to the owner and after unlock time
    function withdraw(address user, uint256 amount) public payable Afterunlocktime
    {
        require(balanceOf[msg.sender] >= amount * 1 ether,"You dont have funds to withdraw");
        balanceOf[msg.sender] -= amount * 1 ether;
        payable(user).transfer(amount * 1 ether); // Transfer the funds to the accounts
    }

    // Function to check if the unlock time has passed
    function Isunlocktime() public view returns (bool) {
        return block.timestamp >= unlocktime;
    }
}
