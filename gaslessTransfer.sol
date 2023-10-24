// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a gasless transfer

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract gaslessTransfer {
    address public owner;
    address public relayer;
    IERC20 public token;

    event TransferRequestCreated(address indexed from, address indexed to, uint256 amount);

    struct TransferRequest {
        address from;
        address to;
        uint256 amount;
    }

    mapping(uint256 => TransferRequest) public transferRequests;
    uint256 public requestCount; // Track the total number of transfer requests

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        requestCount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyRelayer() {
        require(msg.sender == relayer, "Only the relayer can call this function");
        _;
    }

    // Owner can change the contract owner.
    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // Owner can set the relayer address.
    function setRelayer(address newRelayer) public onlyOwner {
        relayer = newRelayer;
    }

    // Create a new transfer request with the specified recipient and amount.
    function requestTransfer(address to, uint256 amount) external {
        requestCount++;
        transferRequests[requestCount] = TransferRequest(msg.sender, to, amount);
        emit TransferRequestCreated(msg.sender, to, amount);
    }

    // Execute the most recent transfer request added to the queue.
    function executeTransfer() external onlyRelayer {
        require(requestCount > 0, "No pending transfer requests");
        TransferRequest storage request = transferRequests[requestCount];
        require(request.from != address(0), "No pending transfer requests");
        require(token.transferFrom(request.from, request.to, request.amount), "Transfer failed");
        delete transferRequests[requestCount];
        requestCount--;
    }
}
