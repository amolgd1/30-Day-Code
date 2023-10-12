// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

contract MultiSig {
    // An array to store the addresses of the contract owners.
    address[] public owners;
    
    // The number of owner confirmations required for a transaction.
    uint public numConfirmationRequired;

    struct Transaction {
        // The target address for the transaction.
        address to;
        
        // The amount in wei to be transferred.
        uint value;
        
        // A flag indicating whether the transaction has been executed.
        bool executed;
    }

    // Mapping to keep track of whether each owner has confirmed a transaction.
    mapping(uint256 => mapping(address => bool)) isConfirmed;

    // Array to store pending transactions.
    Transaction[] public transactions;

    event TransactionSubmitted(uint transactionsId, address sender, address receiver, uint amount);
    event TransactionConfirmed(uint transactionsId);
    event TransactionExecuted(uint transactionsId);

    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        // Ensure there are more than one owner and numConfirmationRequired is valid.
        require(_owners.length > 1, "Owners required must be greater than 1");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length, "Number of confirmations not in sync with the number of owners");
        
        // Initialize the owners array with the provided addresses.
        for (uint i = 0; i < _owners.length; i++) {  
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }

    // Function to deposit funds into the contract.
    function deposit() public payable {}

    // Function to submit a new transaction.
    function submitTransaction(address _to, uint _value) public payable {
        // Convert the value to wei and validate the target address and amount.
        uint valueInWei = _value * 1 ether;
        require(_to != address(0), "Invalid Address");
        require(valueInWei > 0, "Transfer amount must be greater than zero");
        uint transactionsId = transactions.length;
        
        // Create and store the new transaction.
        transactions.push(Transaction({to: _to, value: valueInWei, executed: false}));
        emit TransactionSubmitted(transactionsId, msg.sender, _to, valueInWei);
    }

    // Function for an owner to confirm a transaction.
    function confirmTransaction(uint _transactionsId) public {
        // Ensure the transaction ID is valid and not already confirmed.
        require(_transactionsId < transactions.length, "Invalid TransactionId");
        require(!isConfirmed[_transactionsId][msg.sender], "Transaction Already Confirmed");
        
        // Mark the owner's confirmation and emit the confirmation event.
        isConfirmed[_transactionsId][msg.sender] = true;
        emit TransactionConfirmed(_transactionsId);

        // If the transaction is confirmed by enough owners, execute it.
        if (isTransactionConfirmed(_transactionsId)) {
            executeTransaction(_transactionsId);
        }
    }
    
    // Function to execute a confirmed transaction.
    function executeTransaction(uint _transactionsId) public payable {
        // Ensure the transaction ID is valid and the transaction is not already executed.
        require(_transactionsId < transactions.length, "Invalid TransactionId"); 
        require(!transactions[_transactionsId].executed, "Transaction already executed");
        
        // Mark the transaction as executed and attempt the transfer.
        transactions[_transactionsId].executed = true;
        (bool success, ) = transactions[_transactionsId].to.call{value: transactions[_transactionsId].value}("");
        require(success, "Transaction execution failed"); 
        
        // Emit the execution event.
        emit TransactionExecuted(_transactionsId);
    } 

    // Function to check if a transaction is confirmed by the required number of owners.
    function isTransactionConfirmed(uint _transactionsId) internal view returns (bool) {
        // Ensure the transaction ID is valid.
        require(_transactionsId < transactions.length, "Invalid TransactionId");
        uint confirmationCount; // Initially will be zero

        // Count the number of owner confirmations for the transaction.
        for (uint i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionsId][owners[i]]) {
                confirmationCount++;
            }
        }
        return confirmationCount >= numConfirmationRequired;
    }   
}
