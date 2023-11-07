// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ebayAuction{
    
    struct Auction {
        uint id;
        address payable seller;
        string name;
        string description;
        uint min;
        uint auctionRunTime;
        uint bestOfferId;
        uint[] offerIds;
    }

    struct Offer{
        uint id;
        uint auctionId;
        address payable buyer;
        uint price;
    }

    mapping(uint=>Auction) public auctions;
    mapping(uint=>Offer) private offers;
    mapping(address=>uint[]) private auctionList;
    mapping(address=>uint[]) private offerList;

    uint private newAuctionId = 1;
    uint private newOfferId = 1;

    function createAuction(string calldata _name, string calldata _description, uint _min , uint _auctionRunTimeInMinutes) external {
        require(_min > 0,"Minimum amount must be greater than 0");
        uint[] memory offerIds = new uint[](0);

        Auction storage auction = auctions[newAuctionId];
        auction.id = newAuctionId;
        auction.seller = payable(msg.sender);
        auction.name = _name;
        auction.description = _description;
        auction.min = _min;
        auction.auctionRunTime = block.timestamp + (_auctionRunTimeInMinutes * 1 minutes);
        auction.bestOfferId = 0;
        auction.offerIds = offerIds; 
        auctionList[msg.sender].push(newAuctionId);
        newAuctionId++;
    }

    function createOffer(uint _auctionId) external payable{
        Auction storage auction = auctions[_auctionId];
        Offer storage bestOffer = offers[auction.bestOfferId];
        require(block.timestamp <= auction.auctionRunTime,"This auction is already ended");

        require(msg.value >= auction.min && msg.value > bestOffer.price,"value must be greater than minimum");
        auction.bestOfferId = newOfferId;
        auction.offerIds.push(newOfferId);

        offers[newOfferId] = Offer(newOfferId, _auctionId, payable(msg.sender), msg.value);
        offerList[msg.sender].push(newOfferId);
        newOfferId++;
    }

    function transaction(uint _auctionId) public{
        Auction storage auction = auctions[_auctionId];
        Offer storage bestOffer = offers[auction.bestOfferId];
        require(block.timestamp >= auction.auctionRunTime,"Auction is not ended yet");
        require(msg.sender == auction.seller,"Only auction seller can call transaction");

        for(uint i=0; i<auction.offerIds.length; i++){
            uint offerId = auction.offerIds[i];

            if(offerId != auction.bestOfferId){
                Offer storage offer = offers[offerId];
                offer.buyer.transfer(offer.price);

            }
        }
        auction.seller.transfer(bestOffer.price);
    }
}