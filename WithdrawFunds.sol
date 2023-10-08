// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to withdraw funds from a smart contract ****////

pragma solidity ^0.8.0;

contract Withdrawfund {
    address owner;

    constructor() {
        // Constructor sets the contract owner to the address that deploys the contract
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        // Modifier to restrict access to certain functions to the contract owner only
        require(owner == msg.sender, "Only the owner can call this function");
        _;
    }

    function deposit()  public payable
    {
        // This function allows anyone to deposit funds into the contract.
        // It's marked as payable to accept incoming Ether transactions.
    }

    function withdraw(address user, uint256 amount) public payable OnlyOwner {
        // This function allows the contract owner to withdraw Ether from the contract 
        // and send it to the specified 'user' address.
        payable(user).transfer(amount * 1 ether);
    }

    function balance(address user) public view returns (uint256) {
        // This function allows anyone to query the balance of the 'user' address.
        return address(user).balance;
    }
}
