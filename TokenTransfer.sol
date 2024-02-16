// SPDX-License-Identifier: MIT

// *** Write a Solidity function to transfer tokens from one address to another *** //

pragma solidity >0.5.0 <0.9.0;

contract tokenTransfer {
    string name = "Simple Token"; // token name
    string symbol = "ST"; // token symbol
    uint256 decimals = 18; // token decimals

    uint256 public totalSupply; // total token supply
    mapping(address => uint256) public balanceOf; // mapping to track balance of each address

    event Transfer(address indexed from, address indexed to, uint256 indexed amount);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** (uint256(decimals)); // // Initialize the total supply, multiplying by 10^18 to account for decimals
        balanceOf[msg.sender] = totalSupply; // assign a total supply into contract creator
        emit Transfer(address(0), msg.sender, totalSupply); // emit a Transfer event to log the initial supply transfer to the contract creator
    }

    function transferToken(address to, uint256 amount) public {
        require(to != address(0), "receiver address is null");
        require(balanceOf[msg.sender] >= amount, "Insufficiant balance");

        balanceOf[msg.sender] -= amount; // I am using lodic here to transfer amount
        balanceOf[to] += amount; // add amount to recipient's account

        emit Transfer(msg.sender, to, amount); // emit Transfer event to log a token transfer
    }
}
