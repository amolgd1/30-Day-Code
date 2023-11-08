// SPDX-License-Identifier: MIT

////Write a Solidity function to implement a decentralized insurance platform, 
// where users can purchase insurance policies and file claims ****///

pragma solidity ^0.8.19;

contract insurancePlatform {
    address Owner;
    struct Policy {
        address user;
        uint premium;
        uint payout;
        uint expirationDate;
        bool active;
    }

    struct Claim {
        address user;
        uint amount;
        bool resolved;
    }

    mapping(address => Policy) public policies;
    mapping(address => Claim[]) public claims;

    event PolicyPurchased(address user, uint premium, uint payout);
    event ClaimFiled(address user, uint amount);

    constructor(){
        Owner = msg.sender;
    }

    modifier onlyOwner(){
        require(Owner==msg.sender,"Only owner can call this function");
        _;
    }

    function purchasePolicy(uint _payout, uint _durationInMinutes) public payable {
        require(msg.value > 0, "Premium should be greater than zero");
        require(!policies[msg.sender].active, "User already has an active policy");

        uint expiration = block.timestamp + _durationInMinutes * 1 minutes;
        policies[msg.sender] = Policy(msg.sender, msg.value, _payout, expiration, true);

        emit PolicyPurchased(msg.sender, msg.value, _payout);
    }

    function fileClaim(uint _amount) public {
        require(policies[msg.sender].active, "No active policy found");
        require(block.timestamp < policies[msg.sender].expirationDate, "Policy expired");

        claims[msg.sender].push(Claim(msg.sender, _amount, false));
        emit ClaimFiled(msg.sender, _amount);
    }

    function resolveClaim(address _user, uint _claimIndex, bool _approved) public onlyOwner{
        require(_claimIndex < claims[_user].length, "Invalid claim index");

        if (_approved) {
            // Payout the claim amount to the user
            payable(_user).transfer(claims[_user][_claimIndex].amount);
        }

        claims[_user][_claimIndex].resolved = true;
    }

    function getPolicyDetails(address _user) public view returns (address, uint, uint, uint, bool) {
        Policy memory policy = policies[_user];
        return (policy.user, policy.premium, policy.payout, policy.expirationDate, policy.active);
    }

    function getClaims(address _user) public view returns (Claim[] memory) {
        return claims[_user];
    }
}
