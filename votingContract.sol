// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a voting system, where each address can vote only once.

pragma solidity >0.5.0 <0.9.0;

// Define the Voting contract.
contract Voting {
    // Define a struct to represent a voter.
    struct Voter {
        bool hasVoted; // Indicates whether the voter has already voted.
        uint256 candidates; // The candidate the voter has voted for.
    }

    // Declare state variables for the contract.
    uint256 public totalCandidates; // Total number of candidates.
    uint256 public votingEndTime; // End time of the voting period.

    // Create a mapping to store voter information.
    mapping(address => Voter) public voters;

    // Create an array to store the vote count for each candidate.
    uint256[] public CandidatesvoteCount;

    // Declare an event to log the voting process.
    event Voted(address indexed voter, uint256 candidate);

    // Constructor to initialize the contract with total candidates and voting duration.
    constructor(uint256 _totalCandidates, uint256 _votingTimeMinutes) {
        totalCandidates = _totalCandidates;
        votingEndTime = block.timestamp + (_votingTimeMinutes * 1 minutes);
        CandidatesvoteCount = new uint256[](totalCandidates);
    }

    // Modifier to ensure that voting is still open.
    modifier votingOpen() {
        require(block.timestamp < votingEndTime, "Voting is closed");
        _;
    }

    // Function for voters to cast their votes.
    function Vote(uint256 candidate) public votingOpen {
        require(candidate <= totalCandidates, "Invalid Candidate");
        require(!voters[msg.sender].hasVoted, "Already Voted");

        // Record the vote and update the vote count for the candidate.
        voters[msg.sender] = Voter(true, candidate);
        CandidatesvoteCount[candidate]++;
        emit Voted(msg.sender, candidate);
    }

    // Function to get the vote count for a specific candidate.
    function getVoteCount(uint256 candidate) public view returns (uint256) {
        require(candidate < totalCandidates, "Invalid Candidate");
        return CandidatesvoteCount[candidate];
    }

    // Function to check if the voting period has ended.
    function hasVoted() public view returns (bool) {
        return (block.timestamp >= votingEndTime);
    }
}
