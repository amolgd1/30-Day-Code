// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a time-locked contract,
//  which allows funds to be withdrawn only after a certain time has elapsed. ****////

pragma solidity >0.5.0 <0.9.0;

contract timeLock {
    address public owner; // Address of the contract owner
    uint256 public unlocktime; // Timestamp when funds can be unlocked

    constructor(uint256 unlocktimeMinutes) {
        owner = msg.sender; // Set the owner to the address that deployed the contract
        unlocktime = block.timestamp + (unlocktimeMinutes * 1 minutes); // Calculate the unlock time
    }

    // Modifier to restrict a function to only be callable by the owner
    modifier OnlyOwner() {
        require(owner == msg.sender, "Only the owner can call this function");
        _;
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
        // This function doesn't have any specific logic for deposits.
        // It simply allows the contract to receive Ether.
        // The deposited Ether will be locked until the unlock time.
    }

    // Function to withdraw funds from the contract, restricted to the owner and after unlock time
    function withdraw(address account, uint256 amount) public payable OnlyOwner Afterunlocktime
    {
        payable(account).transfer(amount * 1 ether); // Transfer the funds to the accounts
    }

    // Function to check if the unlock time has passed
    function Isunlocktime() public view returns (bool) {
        return block.timestamp >= unlocktime;
    }
}
