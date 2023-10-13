// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LotteryContract {
    address public manager; // Address of the manager who initiates and ends the lottery
    address[] public players; // List of participants' addresses
    uint public ticketPrice = 1; // Ticket price in Ether
    address public lastWinner; // Address of the last winner

    constructor() {
        manager = msg.sender; // Set the manager as the contract creator
    }

    function enter() public payable {
        uint ticketPriceinWei = ticketPrice * 1 ether; // Calculate the ticket price in Wei
        require(msg.value >= ticketPriceinWei, "Minimum ticket price is 1 Ether"); 
        players.push(msg.sender); // Add the sender's address to the list of participants
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players))); 
        // Generate a pseudo-random number based on various factors
    }

    function pickWinner() public restricted {
        uint index = random() % players.length; // Randomly select a winner's index
        lastWinner = players[index]; // Record the address of the last winner
    }

    function sendWinningAmount() public restricted {
        require(lastWinner != address(0), "No winner has been picked yet"); 
        uint prizeAmount = address(this).balance; // Get the contract's current balance
        address payable winnerAddress = payable(lastWinner); // Cast the winner's address as payable
        lastWinner = address(0); // Reset the last winner
        winnerAddress.transfer(prizeAmount); // Transfer the prize to the winner
    }

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function"); 
        _;
    }

    function getPlayers() public view returns (address[] memory) {
        return players; 
    }
}
