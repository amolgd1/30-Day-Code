// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized advertising platform,
//  where users can earn rewards for viewing and interacting with ads. ****////

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract advertising{
    IERC20 public token;
    struct Ad{
        address advertisier;
        string tital;
        uint runDuration;
        uint budget;
        bool ended;
    }
    uint public adsCount;
    mapping(uint=>Ad) public ads;
    
    event AdCreated(address adCreator );
    constructor(address _token){
        token = IERC20(_token);
    }

    function createAd(string memory _title, uint _runDurationInMinutes, uint _budget) public{
        adsCount++;
        Ad storage ad= ads[adsCount];
        ad.advertisier= msg.sender;
        ad.tital = _title;
        ad.runDuration= block.timestamp + ( _runDurationInMinutes * 1 minutes);
        ad.budget = _budget;
        require(ad.budget > 0,"Ad budget cant be 0");
        ad.ended = false;
        token.transferFrom(msg.sender,address(this),_budget);
    }

     function watchAds(uint _adId) public {
        require(_adId <= adsCount, "Invalid Ad ID");
        Ad storage ad = ads[_adId];
        require(!ad.ended, "Ad is already ended");
        require(ad.budget >= 1, "Budget is insufficient for this ad");
        ad.budget--; // Decrease the ad's budget by 1 for each watch
        ad.ended = (ad.budget == 0); // Mark the ad as ended if the budget becomes zero
        token.transfer(msg.sender, 1); // Transfer 1 token to the user for watching the ad
    }

    function deleteAd(uint _adId) public{
        Ad storage ad = ads[_adId];
        require(msg.sender == ad.advertisier,"You are not a advertidier of this ad");
        delete ads[_adId];
        ad.ended = true;
    }

    function checkAdBudget(uint _adId) public view returns(uint){
        Ad storage ad = ads[_adId];
        if(ad.budget == 0){
            return 0;
        } else{
           return ad.budget;
        }

    }

    function isAdEnded(uint _adId) public view returns(bool){
        return ads[_adId].ended;
    }

}


