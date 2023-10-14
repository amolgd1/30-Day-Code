// SPDX-License-Identifier: MIT


//// **** Write a Solidity function to implement a blind auction,
// where bidders submit sealed bids and the highest bidder wins.  ****////

pragma solidity ^0.8.0;

contract blindAuction {
    // Struct to represent a bidder
    struct Bidder {
        bytes32 blindedBid; // Hash of the blinded bid
        uint deposit; // Amount of ether deposited
    }

    address public beneficiary; // Address that will receive the winning bid
    uint public biddingEnd; // End time of the bidding
    uint public revealEnd; // End time of the revealing phase
    bool public ended; // Flag to track if the auction has ended

    mapping(address => Bidder) public bidders; // Mapping of bidders

    address public highestBidder; // Address of the highest bidder
    uint public highestBid; // Amount of the highest bid

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    constructor(uint _biddingTime, uint _revealTime) {
        beneficiary = msg.sender;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    // Reveal your blinded bid. Can only be called during the reveal phase.
    function revealBid(string memory _value, uint _fake, bytes32 _secret) public {
        require(block.timestamp >= biddingEnd && block.timestamp < revealEnd, "Not in the reveal phase");
        Bidder storage sender = bidders[msg.sender];
        require(sender.blindedBid == keccak256(abi.encodePacked(_value, _fake, _secret)), "Bid not properly blinded");
        require(sender.deposit >= _fake, "Deposit not sufficient");

        sender.deposit -= _fake;
        if (!placeBid(msg.sender, uint(keccak256(abi.encodePacked(_value, _secret)))) || _fake > 0) {
            pendingReturns[msg.sender] += _fake;
        }
    }

    // Place a bid with the provided hashed value. This can be called during the bidding phase.
    function placeBid(address _sender, uint _value) internal returns (bool success) {
        if (_value > highestBid) {
            if (highestBidder != address(0)) {
                pendingReturns[highestBidder] += highestBid;
            }
            highestBid = _value;
            highestBidder = _sender;
            success = true;
        }
    }

    // Withdraw a bid that was overbid
    function withdraw() public {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
            }
        }
    }

    // End the auction and send the highest bid to the beneficiary
    function auctionEnd() public {
        require(block.timestamp >= revealEnd, "Auction has not ended yet");
        require(!ended, "Auction has already ended");
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        payable(beneficiary).transfer(highestBid);
    }
}

