// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a rentable storage system, 
// where users can deposit funds into smart contrcat account, rent a storage space, and return a rented storage space.****////

// add***
// function deposit 
// function withdraw
// function rentSpace
// function returnSpace
// function findvacantSpace
// function getSpaceStatus
// function checkduration
// function getduration

pragma solidity ^0.8.20;

contract rentableStorageSystem {
    address public owner;
    uint public StoragePrice = 1 wei; // Price per storage unit set by the owner initially.
    uint public numOfSpaces; // Total number of storage spaces.

    enum SpaceStatus { Vacant, Rented }

    struct StorageSpace {
        SpaceStatus status;
        address renter;
        uint startTime;
        uint duration;
    }

    StorageSpace[] public storageSpaces;
    mapping(address => uint) public userBalance;

    event Deposit(address user, uint amount);
    event Withdraw(address user, uint amount);
    event RentedSpace(address user, uint spaceIndex, uint startTime, uint duration);
    event VacantSpace(address user, uint spaceIndex);

    constructor(uint _numOfSpaces) {
        owner = msg.sender;
        numOfSpaces = _numOfSpaces; // Set the total number of storage spaces during contract deployment.

        // Initialize storage spaces
        for (uint i = 0; i < _numOfSpaces; i++) {
            storageSpaces.push(StorageSpace(SpaceStatus.Vacant, address(0), 0, 0));
        }
    }

    modifier OnlyOwner() {
        require(owner == msg.sender, "Only the owner can call this function.");
        _;
    }

    modifier SpaceExist(uint spaceIndex) {
        require(spaceIndex < storageSpaces.length, "Space does not exist.");
        _;
    }

    // Function to allow users to deposit funds into their account
    function deposit() external payable {
        require(msg.value > 0, "Amount cannot be zero");
        userBalance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function to allow users to withdraw funds from their account
    function withdraw(uint amount) external {
        require(userBalance[msg.sender] >= amount, "Insufficient balance");
        userBalance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // Function for users to rent a storage space
    function rentSpace(uint duration, uint spaceIndex) public {
        // Calculate the end time of the rental period
        duration = block.timestamp + duration * 1 minutes;
        // Ensure that the provided duration is valid
        require(duration > 0, "Invalid duration");
        // Check if the user has enough balance to rent the space for the specified duration
        require(userBalance[msg.sender] >= duration * StoragePrice, "Insufficient balance");
        // Check if the specified storage space index is valid
        require(spaceIndex < storageSpaces.length, "Storage space invalid");

        // Access the storage space based on the specified index
        StorageSpace storage space = storageSpaces[spaceIndex];
        // Ensure that the storage space is currently vacant
        require(space.status == SpaceStatus.Vacant, "Space is already rented");
        
        // Update the storage space status, renter address, start time, and duration
        space.status = SpaceStatus.Rented;
        space.renter = msg.sender;
        space.startTime = block.timestamp;
        space.duration = duration;

        // Deduct the rental fee from the user's balance
        userBalance[msg.sender] -= duration * StoragePrice;

        // Emit an event to indicate the successful rental
        emit RentedSpace(msg.sender, spaceIndex, space.startTime, duration);
    }

    // Function for users to return a rented storage space
    function returnSpace(uint spaceIndex) external SpaceExist(spaceIndex) {
        // Access the storage space based on the specified index
        StorageSpace storage space = storageSpaces[spaceIndex];
        // Ensure that the storage space is currently rented
        require(space.status == SpaceStatus.Rented, "Only rented space can be returned");
        // Check if the rented duration has been completed
        require(block.timestamp > space.duration, "Rented duration not completed");
        // Ensure that the user calling this function is the renter
        require(space.renter == msg.sender, "Only the renter can return the space");

        // Calculate the elapsed time since the start of the rental
        uint elapsedTime = block.timestamp - space.startTime;
        // Calculate the cost based on the elapsed time
        uint cost = (elapsedTime / 3600) * StoragePrice * space.duration;
        // Calculate the refund amount for the user
        uint refund = (space.duration * StoragePrice) - cost;
        // Check if the rented duration is completed and can be returned
        require(checkDuration(spaceIndex) == true, "Rented duration not yet completed");

        // Transfer the rental fee to the contract owner
        payable(owner).transfer(space.duration * StoragePrice);
        // Refund the remaining balance to the user
        userBalance[msg.sender] += refund;

        // Update the storage space status and related information
        space.status = SpaceStatus.Vacant;
        space.renter = address(0);
        space.duration = 0;
        space.startTime = 0;

        // Emit an event to indicate the successful return of the space
        emit VacantSpace(msg.sender, spaceIndex);
    }

    // Function to find the index of a vacant storage space
    function findVacantSpace() public view returns (uint) {
        // Iterate through the storage spaces to find a vacant space
        for (uint i = 0; i < storageSpaces.length; i++) {
            if (storageSpaces[i].status == SpaceStatus.Vacant) {
                // Return the index of the first vacant space found
                return i;
            }
        }
        // If no vacant space is found, return the total number of spaces
        return storageSpaces.length;
    }

    // Function to get the status of a specific storage space
    function getSpaceStatus(uint spaceIndex) public view SpaceExist(spaceIndex) returns (SpaceStatus) {
        return storageSpaces[spaceIndex].status;
    }

    // Function to check if the rented duration has completed for a storage space
    function checkDuration(uint spaceIndex) public view returns (bool) {
        StorageSpace storage space = storageSpaces[spaceIndex];
        return block.timestamp > space.duration;
    }

    // Function to get the duration of a specific storage space
    function getDuration(uint spaceIndex) public view returns (uint) {
        StorageSpace storage space = storageSpaces[spaceIndex];
        return space.duration;
    }
}
