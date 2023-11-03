// SPDX-License-Identifier: MIT


//// **** Write a Solidity function to implement a decentralized reputation system, 
// where users can earn reputation points by messaging in cummunity .  ****////

pragma solidity ^0.8.0;

// function contribute ( string _Ideas )
contract reputationSystem{

    struct Level{
        uint Level1;
        uint Level5;
        uint Level10;
        uint Level15;
        uint MAX_Level;
    }
    mapping(address=>Level) levels;
    struct User{
        address messager;
        uint messageCount;
        uint reputationPoints;
        bool exists;
    }
    uint public userCount;
    mapping(address=>User) public users;
    mapping(address=>string[]) public messages;
    event Message(address messager,string message);

    function sendMessage(string memory _message) public{
        User storage user= users[msg.sender];
        user.messager= msg.sender;
        user.messageCount++;
        user.reputationPoints++;

        if(!user.exists){
            user.exists= true;
            userCount++;
        }
        messages[msg.sender].push(_message);
        updateUserLevel(msg.sender);
        emit Message(msg.sender, _message);
    }

    function updateUserLevel(address _user) internal {
        User storage user = users[_user];
        Level storage level= levels[_user];

        if(user.reputationPoints == 1){
            level.Level1 = user.reputationPoints;
        } else if(user.reputationPoints == 5){
            level.Level5 = user.reputationPoints;
        } else if(user.reputationPoints == 10){
            level.Level10 = user.reputationPoints;
        } else if(user.reputationPoints == 15){
            level.Level15 = user.reputationPoints;
        }

        if(user.reputationPoints == 20){
            level.MAX_Level = user.reputationPoints;
        }
    }

    function getUserReputation(address _user) public view returns(uint256) {
        require(_user==msg.sender,"You only see your own points");
        User storage user= users[msg.sender];
        return user.reputationPoints;
    }

    function getUserLevel(address _user) public view returns(string memory){
        uint reputation = users[_user].reputationPoints;
        string memory level;
        if(reputation >= 20){
            level= "MAX_Level";
        } else if (reputation == 1){
            level= "Level 1";
        } else if(reputation == 5){
            level = "Level 5";
        } else if(reputation == 10){
            level = "Level 10";
        } else if(reputation == 15){
            level = "Level 15";
        } else {
            level = "Need more reputationPoints to pass next level";
        }
        return level;
    }
}