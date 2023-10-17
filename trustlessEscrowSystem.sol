// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a trustless escrow system, 
// where funds are held in escrow until certain conditions are met. ****////

// add*
// function Deposit
// function approve
// function reject
// function confirm 
// function realse
// function refund

pragma solidity ^0.8.0;

contract trustlessEscrowSystem {
    address public buyer; 
    address public seller;
    address public arbiter;  // The arbiter is a trusted third party who can verify conditions.
    bool public buyerApproved;
    bool public sellerApproved;
    bool public fundsReleased;

    mapping(address => uint) public balances;

    modifier OnlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function.");
        _;
    } 

    modifier OnlySeller() {
        require(msg.sender == seller, "Only the seller can call this function.");
        _;
    }

    modifier OnlyArbiter() {
        require(msg.sender == arbiter, "Only the arbiter can call this function.");
        _;
    }

    modifier EscrowNotReleased() {
        require(!fundsReleased, "Escrow funds have already been released.");
        _;
    }
    
    constructor(address _seller, address _arbiter) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
    }

    // Deposit function allows the buyer to deposit funds into the escrow.
    function deposit() public payable OnlyBuyer EscrowNotReleased {

    }

    // Approve function allows the buyer to approve the release of funds.
    function approve() public OnlyBuyer EscrowNotReleased {
        buyerApproved = true;
    }

    // Reject function allows the buyer to reject the release of funds.
    function reject() public OnlyBuyer EscrowNotReleased {
        buyerApproved = false;
    }

    // Confirm function allows the seller to confirm the release of funds.
    function confirm() public OnlySeller EscrowNotReleased {
        sellerApproved = true;
    }

    // Release function, called by the arbiter, releases funds to the seller when both buyer and seller approve.
    function release(uint amount) public OnlyArbiter {
        require(buyerApproved && sellerApproved, "Both buyer and seller must approve before releasing funds.");
        payable(seller).transfer(amount * 1 ether);
        fundsReleased = true;
    }

    // Refund function, called by the arbiter, refunds the funds to the buyer when both parties do not agree.
    function refund(uint amount) public OnlyArbiter {
        require(!buyerApproved && !sellerApproved, "Both buyer and seller must not approve for a refund.");
        payable(buyer).transfer(amount * 1 ether);
        fundsReleased = true;
    }
}
