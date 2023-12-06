// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to withdraw funds from a smart contract ****////

pragma solidity ^0.8.0;

contract Withdrawfund {

    mapping(address=>uint) public balanceOf;

    function deposit() public payable{
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(address user,uint amount) public{
        amount = amount * 1 ether;
        require(balanceOf[msg.sender] >= amount,"You dont have funds to withdraw");
        require(amount > 0,"Amount must be greater than 0");

        balanceOf[msg.sender] -= amount;
        balanceOf[user] += amount; 
        payable(user).transfer(amount);
    }

}