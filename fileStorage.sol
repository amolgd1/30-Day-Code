// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized file storage system,
// where users can store and retrieve files without relying on a centralized server. ****////


pragma solidity ^0.8.19;

contract FileStorage {
    
    struct Access {
        address user;
        bool access; // true or false
    }
    
    mapping(address => string[]) value;        // Maps user addresses to an array of URLs
    mapping(address => Access[]) accessList;    // Maps user addresses to an array of Access structures
    mapping(address => mapping(address => bool)) ownership;      // Maps user addresses to ownership status with other users
    mapping(address => mapping(address => bool)) previousData;   // Maps user addresses to a history of data access with other users

    function add(address _user, string memory _url) external {
        value[_user].push(_url);  // Allows a user to add a URL to their storage
    }

    function allow(address user) external {
        ownership[msg.sender][user] = true;  // Grants ownership to another user
        if (previousData[msg.sender][user]) {
            for (uint i = 0; i < accessList[msg.sender].length; i++) {
                if (accessList[msg.sender][i].user == user) {
                    accessList[msg.sender][i].access = true; // Updates access to true for the user
                }
            }
        } else {
            accessList[msg.sender].push(Access(user, true));  // Creates a new Access record with true access
            previousData[msg.sender][user] = true;
        }
    }

    function disallow(address user) external {
        ownership[msg.sender][user] = false;  // Revokes ownership from another user
        for (uint i = 0; i < accessList[msg.sender].length; i++) {
            if (accessList[msg.sender][i].user == user) {
                accessList[msg.sender][i].access = false;  // Updates access to false for the user
            }
        }
    }

    function display(address _user) external view returns (string[] memory) {
        require(_user == msg.sender || ownership[_user][msg.sender], "You don't have access");  // Checks if the caller has access to view the URLs of the specified user
        return value[_user];
    } 

    function shareAccess() public view returns (Access[] memory) {
        return accessList[msg.sender];  // Returns the access list for the caller's address
    }
}
