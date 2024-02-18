// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a voting system,
// where each address can vote only once .

pragma solidity 0.8.19;

// Define the Voting contract.
contract Voting {
    address private immutable owner;
    // Define a struct to represent a voter.
    struct Voter {
        bool hasVoted; // Indicates whether the voter has already voted.
        uint256 candidates; // The candidate the voter has voted for.
        uint256 votingRound;
    }

    // Declare state variables for the contract.
    uint256 public currentRound; // to track current voting round so people can participants only once at each voting round
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
        owner = msg.sender;
        totalCandidates = _totalCandidates;
        votingEndTime = block.timestamp + (_votingTimeMinutes * 1 minutes);
        CandidatesvoteCount = new uint256[](totalCandidates + 1);
        currentRound = 1;
    }

    // Modifier to ensure that voting is still open.
    modifier votingOpen() {
        require(block.timestamp < votingEndTime, "Voting is closed");
        _;
    }

    modifier votingClose(){
        require(block.timestamp > votingEndTime,"Voting is already open");
        _;
    }


    modifier OnlyOwner() {
        require(msg.sender == owner, "owner require");
        _;
    }

    function addCandidates(uint256 _newCandidates) external OnlyOwner{
        require(_newCandidates > totalCandidates,"Candidate alreay exist");
        totalCandidates = _newCandidates;
    }

    function startNewVoting(uint256 _votingEndTimeInMinutes) external OnlyOwner votingClose{
        currentRound++;
        if(!hasEnded()){
            revert("last voting not ended yet");
        }
        uint votingEt = block.timestamp + (_votingEndTimeInMinutes * 1 minutes);

        require(votingEt > block.timestamp,"voting end time must be in future");
        votingEndTime = votingEt;
    }

    // Function for voters to cast their votes.
    function Vote(uint256 candidate) public votingOpen {
        require(candidate > 0,"must be valid");
        require(candidate <= totalCandidates, "Invalid Candidate");
        require(
            !voters[msg.sender].hasVoted || voters[msg.sender].votingRound < currentRound,"Already Voted this round");

        // Record the vote and update the vote count for the candidate.
        voters[msg.sender] = Voter(true, candidate, currentRound);
        CandidatesvoteCount[candidate]++;
        
        if(hasEnded()){
            delete votingEndTime;
        }
        emit Voted(msg.sender, candidate);
    }

    // Function to get the vote count for a specific candidate.
    function getVoteCount(uint256 candidate) public view returns (uint256) {
        require(candidate < totalCandidates, "Invalid Candidate");
        return CandidatesvoteCount[candidate];
    }

    // Function to check if the voting period has ended.
    function hasEnded() public view returns (bool) {
        return (block.timestamp >= votingEndTime);
    }
}
