// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a decentralized real-time bidding platform,
//  where advertisers can bid on ad space in real time. ****////

pragma solidity ^0.8.0;

contract RealTimeBidding {
    struct Bid {
        address bidder; // Address of the bidder
        uint256 amount; // Bid amount
    }

    address public owner; // Address of the owner of the contract
    uint256 public currentHighestBid; // Current highest bid amount
    address payable public currentHighestBidder; // Address of the current highest bidder
    uint256 public biddingEndTime; // End time for bidding
    bool public biddingClosed; // Flag to indicate if bidding is closed

    // Maps the bidder's address to their available balance
    mapping(address => uint256) public bidderBalances;

    // Maps the bidder's address to their pending bid
    mapping(address => Bid) public pendingBids;

    event NewBid(address bidder, uint256 amount); // Event to log new bids
    event BiddingClosed(address winner, uint256 amount); // Event to log the bidding closure

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyBeforeBiddingEnd() {
        require(block.timestamp < biddingEndTime, "Bidding has already ended.");
        _;
    }

    modifier onlyAfterBiddingEnd() {
        require(block.timestamp >= biddingEndTime, "Bidding has not yet ended.");
        _;
    }

    // Function to start the bidding with a specified duration
    function startBidding(uint256 durationInMinutes) external onlyOwner {
        require(!biddingClosed, "Bidding is already closed.");
        biddingEndTime = block.timestamp + durationInMinutes * 1 minutes;
    }

    // Function for advertisers to place a bid
    function placeBid() external payable onlyBeforeBiddingEnd {
        require(msg.value > 0, "Bid amount must be greater than 0");
        require(msg.sender != currentHighestBidder, "You are already the highest bidder.");

        if (currentHighestBidder != address(0)) {
            bidderBalances[currentHighestBidder] += currentHighestBid;
        }

        // Update the pending bid and current highest bid
        pendingBids[msg.sender] = Bid({bidder: msg.sender, amount: msg.value});
        currentHighestBid = msg.value;
        currentHighestBidder = payable(msg.sender);

        emit NewBid(msg.sender, msg.value);
    }

    // Function to close the bidding and transfer the ad space to the highest bidder
    function closeBidding() external onlyOwner onlyAfterBiddingEnd {
        require(!biddingClosed, "Bidding is already closed.");
        biddingClosed = true;

        // Transfer the ad space to the highest bidder
        currentHighestBidder.transfer(currentHighestBid);

        emit BiddingClosed(currentHighestBidder, currentHighestBid);
    }

    // Function for bidders to withdraw their unused funds
    function withdraw() external {
        uint256 amount = bidderBalances[msg.sender];
        require(amount > 0, "You have no funds to withdraw.");
        bidderBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Function to get the details of the current highest bid
    function getCurrentBidDetails() external view returns (address, uint256) {
        return (currentHighestBidder, currentHighestBid);
    }
}
