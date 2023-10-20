// SPDX-License-Identifier: MIT


//// **** Write a Solidity function to implement a decentralized autonomous organization (DAO),
// where users can vote on governance decisions.  ****////

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAOvotingContract {
    IERC20 public token;
    address public manager;
    uint public deadline;
    address[] public tokenHolders; // List of token holder addresses
    uint public numTokenHolders;  // Total number of token holders

    // Structure to represent a proposal
    struct Proposal {
        string description;
        address payable to;
        uint value;
        bool completed;
        uint numOfVoters; // Number of voters for this proposal
        mapping(address => bool) voters; // Mapping to track who has voted for this proposal
    }

    mapping(uint => Proposal) public proposals; // Mapping of proposal IDs to Proposal structs
    uint public numOfProposals; // Total number of proposals

    // Modifier to restrict access to the manager of the contract
    modifier OnlyManager() {
        require(manager == msg.sender, "Only the manager can call this function");
        _;
    }

    // Constructor to initialize the contract with token holders, token address, and deadline
    constructor(address[] memory _tokenHolders, address _token, uint _deadline) {
        token = IERC20(_token);
        manager = msg.sender;
        deadline = block.timestamp + _deadline * 1 minutes;
        tokenHolders = _tokenHolders;
    }

    // Function to accept deposits (not used in this example)
    function Deposit() public payable {}

    // Function to create a new proposal
    function createProposal(string memory _description, address payable _to, uint _value) public OnlyManager {
        Proposal storage p = proposals[numOfProposals];
        p.description = _description;
        p.to = _to;
        p.value = _value;
        p.completed = false;
        p.numOfVoters = 0;
        numOfProposals++;
    }

    // Function to allow users to vote on a proposal
    function voteProposal(uint _proposalId) public {
        require(_proposalId < numOfProposals, "Invalid proposalId");
        require(block.timestamp < deadline, "Voting period has ended");
        uint bal = token.balanceOf(msg.sender);
        require(bal > 0, "You don't have voting power");
        Proposal storage thisProposal = proposals[_proposalId];
        require(!thisProposal.voters[msg.sender], "You have already voted");
        thisProposal.voters[msg.sender] = true;
        thisProposal.numOfVoters++;
    }

    // Function to execute a proposal if it receives majority support
    function executeProposal(uint _proposalId) public {
        require(_proposalId < numOfProposals, "Invalid proposalId");
        Proposal storage thisProposal = proposals[_proposalId];
        require(!thisProposal.completed, "This proposal is already completed");
        require(thisProposal.numOfVoters > numTokenHolders / 2, "More voters needed");
        
        (bool success, ) = thisProposal.to.call{value: thisProposal.value}("");
        require(success, "Transfer failed");
        
        thisProposal.completed = true;
    }

    // Function to check the balance of the contract (token balance)
    function getBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    // Function to update the total number of token holders (called after the voting period)
    function updateTokenHolders() public {
        require(block.timestamp >= deadline, "Voting period has not ended yet");
        numTokenHolders = tokenHolders.length;
    }
}
