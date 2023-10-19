// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized exchange, 
// where users can trade ERC-20 tokens. ****////

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract decentralizedExchange {

    // The ERC20 token being traded on this exchange
    IERC20 public token;

    event Bought(uint tokenToBuy); // Event emitted when tokens are purchased
    event Sold(uint amount);       // Event emitted when tokens are sold

    constructor(address _tokenAddress) {
        // Initialize the contract with the specified ERC20 token
        token = IERC20(_tokenAddress);
    }

    function buy() public payable {
        uint amountToBuy = msg.value;   // Amount of Ether sent to buy tokens
        uint dexBalance = token.balanceOf(address(this)); // Check the token balance in the exchange

        require(amountToBuy > 0, "Invalid amount"); // Ensure the purchase amount is valid
        require(amountToBuy <= dexBalance, "Not enough tokens in the reserve"); // Check if there are enough tokens in the exchange

        // Transfer the purchased tokens to the buyer and emit an event
        token.transfer(msg.sender, amountToBuy);
        emit Bought(amountToBuy);
    }

    function sell(uint amount) public {
        require(amount > 0, "Invalid amount"); // Ensure the sell amount is valid

        uint allowance = token.allowance(msg.sender, address(this)); // Check the token allowance granted by the seller
        require(allowance >= amount, "Check the token allowance"); // Ensure the allowance is sufficient

        // Transfer the tokens from the seller to the exchange and transfer Ether to the seller
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);

        emit Sold(amount); // Emit an event to log the successful sale
    }
}
