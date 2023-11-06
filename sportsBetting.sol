// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized sports betting platform,
// where users can bet on the outcome of sports events such as football and basketball games ****////

pragma solidity ^0.8.20;

contract SportsBetting{
    address public owner;
    uint private eventOutcome;
    bool public isSettled;

    struct Bet{
        address bettor;
        uint amount;
        uint predictedOutcome; // we can use intergers to represent diff outComes;
        bool claimed;
    }
    
    mapping(uint=>Bet[]) public bets;

    event NewBetPlaced(address indexed bettor, uint eventId, uint predictedOutcome, uint amount);
    event EventSettled(uint eventId, uint outcome);

    modifier OnlyOwner(){
        require(owner==msg.sender,"you are not a owner");
        _;
    }

    constructor (){
        owner=msg.sender;
    }

    function placeBet(uint _eventId, uint _predictedOutcome) public payable{
        require(!isSettled,"Betting for this event is closed");
        require(msg.value > 0,"Amount must be greater than 0");

        bets[_eventId].push(Bet({
             bettor: msg.sender,
            amount: msg.value,
            predictedOutcome: _predictedOutcome,
            claimed: false
        }));
        emit NewBetPlaced(msg.sender, _eventId, _predictedOutcome, msg.value);
    }

    function settleBet(uint _eventId, uint _Outcome) public OnlyOwner{
        require(!isSettled,"Betting for this event is closed");
        eventOutcome = _Outcome;
        isSettled = true;
        emit EventSettled(_eventId, _Outcome);
    }

    function ClaimWinning(uint _eventId) external{
        require(isSettled==true,"This betting event is not settled yet");
        require(bets[_eventId].length >= 2,"minimum two bettors required");
        
        uint winningAmount = 0;

        address payable winner;
        address payable loser;
        bool isTie= false;

        for(uint i=0; i<bets[_eventId].length; i++){
            Bet storage bet = bets[_eventId][i];

            if(bet.predictedOutcome == eventOutcome && !bet.claimed){
                if(winner == address(0)){
                    winner = payable(bet.bettor);
                    winningAmount = bet.amount * 2; // Sum up the winning amounts (assuming 1:1 odds)
                } else{
                    loser=payable(bet.bettor);
                    isTie = true;
                }
                bet.claimed = true;
            }
        }

        require(winningAmount > 0 || isTie ,"No winning bets for this outcome");

            if(winningAmount > 0 && !isTie){
                winner.transfer(winningAmount);
                loser.transfer(0);
            } else if(isTie){
                for(uint i=0; i<bets[_eventId].length; i++){
                    Bet storage bet = bets[_eventId][i];
                    if(!bet.claimed){
                        bet.claimed = true;
                    }
                    payable(bet.bettor).transfer(bet.amount); //Return the bet amount to each player in a tie
                }
                
            }

    }
    
}