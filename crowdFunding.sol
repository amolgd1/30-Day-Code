// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a crowdFunding, ****//// 

pragma solidity >0.5.0 <0.9.0;

contract crowdFunding {
    // State variables
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedamount;
    uint public noOfContributors;
    mapping(address => uint256) public contributors;

    // Request struct
    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }

    // Mapping of request index to Request struct
    mapping(uint => Request) public requests;
    uint public numRequests;

    // Constructor to initialize the contract
    constructor(uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline * 1 minutes;
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    // Function for contributors to send Ether
    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value >= minimumContribution, "Minimum amount is not met");

        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedamount += msg.value;
    }

    // Function to get the contract balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Function for contributors to request a refund
    function refund() public {
        require(block.timestamp > deadline && raisedamount < target, "You are not eligible for a refund");
        require(contributors[msg.sender] > 0);
        address payable user = payable(msg.sender);
        contributors[msg.sender] = 0;
        user.transfer(contributors[msg.sender]);
    }

    // Modifier to restrict access to the manager
    modifier OnlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    // Function for the manager to create a payment request
    function createRequest(string memory _description, address payable _recipient, uint _value) public OnlyManager {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    // Function for contributors to vote on a payment request
    function voteRequest(uint _requestNo) public {
        require(_requestNo <= numRequests, "Invalid Request");
        require(contributors[msg.sender] > 0, "You must be a contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] == false, "You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    // Function for the manager to make a payment from the contract
    function makePayment(uint _requestNo) public OnlyManager {
        require(raisedamount >= target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "This request is already completed");
        require(thisRequest.noOfVoters > noOfContributors / 2, "Majority has not voted");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
