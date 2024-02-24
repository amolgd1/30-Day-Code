// SPDX-License-Identifier: MIT

// Smart contract for a rentable storage system where users can deposit funds, rent storage space, and return rented space.

pragma solidity 0.8.19;

contract StorageSystem {
    address public immutable owner;
    uint256 public storagePrice = 1000 wei; // Cost per unit of storage space in wei
    uint256 public numOfSpaces; // Total number of available storage spaces

    enum SpaceStatus {
        Rented,
        Vacant
    }

    struct StorageSpace {
        SpaceStatus status;
        address renter;
        uint256 starttime;
        uint256 duration;
    }

    StorageSpace[] public storageSpaces; // Array to store information about each storage space
    mapping(address => uint256) public userBalance; // Mapping to store user balances

    // Constructor to initialize the contract with the given number of storage spaces
    constructor(uint256 _numOfSpaces) {
        owner = msg.sender;
        numOfSpaces = _numOfSpaces;

        // Initialize each storage space as vacant
        for (uint256 i; i < _numOfSpaces; i++) {
            storageSpaces.push(StorageSpace(SpaceStatus.Vacant, address(0), 0, 0));
        }
    }

    // Function to deposit funds into the contract
    function deposit() public payable {
        require(msg.value > 0, "Invalid amount");
        userBalance[msg.sender] += msg.value;
    }

    // Function to withdraw funds from the contract
    function withdraw(uint256 amount) external payable {
        require(userBalance[msg.sender] >= amount, "Insufficient funds to withdraw");
        userBalance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Function to rent a storage space for a specified duration
    function rentSpace(uint256 _durationInMinutes, uint256 _spaceIndex) external {
        uint256 duration = block.timestamp + (_durationInMinutes * 1 minutes);
        require(duration > 0, "Duration must be in the future");
        require(_spaceIndex < storageSpaces.length, "Invalid space id");
        require(userBalance[msg.sender] > storagePrice, "Insufficient funds to purchase space");

        StorageSpace storage space = storageSpaces[_spaceIndex];
        require(space.status == SpaceStatus.Vacant, "This space is already rented");

        // Mark the space as rented and record the renter's information
        space.status = SpaceStatus.Rented;
        space.renter = msg.sender;
        space.duration = duration;
        space.starttime = block.timestamp;

        // If the current time exceeds the duration, immediately return the space
        if (block.timestamp >= space.duration) {
            returnSpaceAfterDuration(_spaceIndex);
        }
    }

    // Internal function to return a rented space after the specified duration has passed
    function returnSpaceAfterDuration(uint256 _spaceIndex) internal {
        require(_spaceIndex < storageSpaces.length, "Invalid space");
        StorageSpace storage space = storageSpaces[_spaceIndex];
        require(space.status == SpaceStatus.Rented, "Only rented spaces can be returned");
        require(space.renter == msg.sender, "You are not the renter of this space");
        require(block.timestamp >= space.duration, "Rented time not completed yet");

        // Calculate the cost and transfer funds to the owner
        uint256 cost = space.duration * storagePrice;
        userBalance[msg.sender] -= cost;
        (bool send, ) = payable(owner).call{value: cost}("");
        require(send, "Fund transfer failed");

        // Reset the space to vacant
        space.status = SpaceStatus.Vacant;
        space.renter = address(0);
        space.duration = 0;
        space.starttime = 0;
    }

    // Function to return a rented space before the duration has ended
    function returnSpaceBeforeDurationEnd(uint256 _spaceIndex) external {
        StorageSpace storage space = storageSpaces[_spaceIndex];
        require(block.timestamp < space.duration, "Rented time has already completed");
        require(space.renter == msg.sender, "You don't rent this space");
        require(space.status == SpaceStatus.Rented, "Only rented spaces can be returned");

        // Calculate the elapsed time and cost, then transfer funds to the owner
        uint256 elapsedTime = block.timestamp - space.starttime;
        uint256 cost = elapsedTime * storagePrice;
        userBalance[msg.sender] -= cost;
        (bool send, ) = payable(owner).call{value: cost}("");
        require(send, "Fund transfer failed");

        // Reset the space to vacant
        space.status = SpaceStatus.Vacant;
        space.renter = address(0);
        space.duration = 0;
        space.starttime = 0;
    }

    // Function to find the index of the first vacant storage space
    function findVacantSpace() external view returns (uint256) {
        for (uint i; i < storageSpaces.length; i++) {
            if (storageSpaces[i].status == SpaceStatus.Vacant) {
                return i;
            }
        }
        return storageSpaces.length; // Return total spaces if none are vacant
    }

    // Function to get the status of a specific storage space
    function getSpaceStatus(uint256 _spaceIndex) external view returns (SpaceStatus) {
        return storageSpaces[_spaceIndex].status;
    }

    // Function to check the remaining duration of a rented space
    function checkDuration(uint256 _spaceIndex) external view returns (uint256) {
        return storageSpaces[_spaceIndex].duration;
    }
}

