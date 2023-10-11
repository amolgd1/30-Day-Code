// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a basic ERC-20 token. ****////
pragma solidity ^0.8.0;

// Define the ERC20Token contract.
contract ERC20Token {
    // ERC-20 Token information
    string public name = "Simple Token";   // The name of the token
    string public symbol = "ST";           // The symbol of the token
    uint256 public decimals = 18;          // The number of decimal places the token can be divided into

    // Total supply of the token
    uint256 public totalSupply;

    // Balances of token holders
    mapping(address => uint256) public balanceOf;

    // Allowances for spending tokens on behalf of others
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events to log token transfers and approvals
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // Constructor to initialize the token with an initial supply
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10**uint256(decimals);  // Convert initial supply to the correct number of tokens
        balanceOf[msg.sender] = totalSupply;                   // Assign the total supply to the contract creator
        emit Transfer(address(0), msg.sender, totalSupply);    // Log the initial token transfer
    }

    // Function to check the balance of the caller
    function balance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }

    // Function to transfer tokens to a specified address
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid recipient address");  // Check for a valid recipient address
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");  // Check if the sender has enough balance

        // Update balances
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        // Log the transfer event
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Function to check the allowance granted by the owner to a spender
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Function to allow another address to spend tokens on behalf of the caller
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;

        // Log the approval event
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function to transfer tokens from one address to another on behalf of the owner
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(from != address(0), "Invalid sender address");  // Check for a valid sender address
        require(to != address(0), "Invalid recipient address");  // Check for a valid recipient address
        require(balanceOf[from] >= amount, "Insufficient balance");  // Check if the sender has enough balance

        // Check if the spender is allowed to spend the specified amount
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");

        // Update balances and allowances
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        _allowances[from][msg.sender] -= amount;

        // Log the transfer event
        emit Transfer(from, to, amount);
        return true;
    }
}
