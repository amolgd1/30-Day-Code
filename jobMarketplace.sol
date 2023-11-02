// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a decentralized job marketplace, 
// where users can find work and hire freelancers without relying on a centralized platform.  ****////

pragma solidity ^0.8.19;


contract jobMarketplace{
    
    struct Job{
        address employer;
        string title;
        string description;
        uint budget;
        bool isOpen;
        address[] applicants;
        mapping(address=>bool) hasApplied;
        address hiredFreelancer;
        bool isCompleted;
    }

    mapping(uint=>Job) jobs;
    uint public jobCount;

    mapping(address=>uint) public balances;

    event jobCreated(address jobPoster, string jobTitle, string jobDescription, uint jobBudget);
    event freelancerApplied(address freelancer, uint jobId);
    event freelancerHired(address freelancer, uint jobId);
    event jobCompleted(uint jobId);

    function deposite()  external payable { 
        balances[msg.sender] += msg.value;
    }

    function withdraw(address user,uint amount) public{
        balances[user] -= amount;
        payable(user).transfer(amount);
    }


    function createJob(string memory _title, string memory _description, uint _budget) external{
        jobCount++;
        Job storage job= jobs[jobCount];
        job.employer = msg.sender;
        job.title = _title;
        job.description= _description;
        job.budget= _budget;
        job.isOpen= true;
        job.applicants= new address[](0);
        job.hiredFreelancer= address(0);
        job.isCompleted= false;
        emit jobCreated(msg.sender, _title, _description, _budget);
    }

    function applyForJob(uint _jobId) external{
        require(_jobId <= jobCount ,"Invalid job");
        require(jobs[_jobId].isOpen, "Job is not open for this application");
        require(!jobs[_jobId].hasApplied[msg.sender],"You have alreadyy apply this job application");

        jobs[_jobId].applicants.push(msg.sender);
        jobs[_jobId].hasApplied[msg.sender]= true;
        emit freelancerApplied(msg.sender, _jobId);
    }

    function hireFreelancer(address _freelancer, uint _jobId) external{
        require(_jobId <= jobCount,"Invalid job application");
        require(msg.sender == jobs[_jobId].employer,"you are not a employer of this job application");
        require(jobs[_jobId].isOpen, "This job application is not open");
        require(jobs[_jobId].hasApplied[_freelancer], " this freelancer is not applied for a job");
        
        jobs[_jobId].isOpen = false;
        jobs[_jobId].hiredFreelancer= _freelancer;
        emit freelancerHired(_freelancer,_jobId);
    }

    function completeJob(uint _jobId) external{
        require(_jobId <= jobCount,"Invalid job application");
        require(msg.sender == jobs[_jobId].employer,"you are not a employer of this job application");
        require(!jobs[_jobId].isCompleted, "Job is already completed");

        jobs[_jobId].isCompleted = true;

        uint payment= jobs[_jobId].budget;
        balances[jobs[_jobId].employer] -= payment;
        balances[jobs[_jobId].hiredFreelancer] += payment;
        emit jobCompleted(_jobId);
    }

    function getJobDetails(uint _jobId) public view returns( 
        address employer,
        string memory title,
        string memory description,
        uint256 budget,
        bool isOpen,
        address[] memory applicants,
        address hiredFreelancer,
        bool isCompleted
        
        ){

        require(_jobId <= jobCount,"invalid job application");
        Job storage job= jobs[_jobId];
        return(
            job.employer,
            job.title,
            job.description,
            job.budget,
            job.isOpen,
            job.applicants,
            job.hiredFreelancer,
            job.isCompleted
        );

        }
        
}