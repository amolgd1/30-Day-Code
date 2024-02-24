// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Multi-signature wallet contract with confirmation requirements

contract MultiSigWallet {
    event Deposit(address indexed spender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );

    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);

    // List of owners and the number of confirmations required for a transaction
    address[] public owners;
    uint public numConfirmationRequired;
    mapping (address=>bool) public isOwner;

    // Mapping to track whether an owner has confirmed a transaction
    // (mapping from tx index => owner => bool)
    mapping (uint => mapping(address=>bool)) public isConfirmed;

    // Struct to represent a transaction
    struct Transaction{
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    // List of all transactions
    Transaction[] public transactions;

    // Constructor to initialize the contract with owners and confirmation requirements
    constructor(address[] memory _owners, uint256 _numConfirmationRequired) {
        require(_owners.length > 0,"owners required");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length,
                "invalid num of required confirmation");

        // Initialize owners and confirmations
        for(uint i = 0; i<_owners.length; i++){
            address owner = _owners[i];

            require(owner != address(0),"invalid owner");
            require(!isOwner[owner],"owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }

    // Modifier to check if the caller is an owner
    modifier OnlyOwner(){
        require(isOwner[msg.sender],"Not owner");
        _;
    }

    // Modifier to check if the transaction index exists
    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length,"transation is not exists");
        _;
    }

    // Modifier to check if the transaction has not been confirmed
    modifier NotConfirmed(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender],"transaction already confirmed");
        _;
    }

    // Modifier to check if the transaction has not been executed
    modifier NotExecuted(uint _txIndex){
        require(!transactions[_txIndex].executed,"transaction already executed");
        _;
    }

    // Receive function to accept Ether deposits
    receive() external payable { 
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Function to deposit Ether
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Function to submit a new transaction
    function submitTransaction(address _to, uint256 _value, bytes memory _data) public OnlyOwner {
        uint txIndex = transactions.length;

        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    // Function to confirm a transaction
    function confirmTransaction(uint _txIndex) public 
        OnlyOwner 
        txExists(_txIndex) 
        NotConfirmed(_txIndex) 
        NotExecuted(_txIndex)  
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    // Function to execute a transaction
    function executeTransaction(uint _txIndex) public 
        OnlyOwner 
        txExists(_txIndex) 
        NotExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= numConfirmationRequired,"more confirmation required");

        transaction.executed = true;

        // Execute the transaction
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success,"tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex); 
    }

    // Function to revoke confirmation for a transaction
    function revokeConfirmation(uint _txIndex) public 
        OnlyOwner
        txExists(_txIndex) 
        NotExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender],"tx is not confirmed");

        isConfirmed[_txIndex][msg.sender] = false;
        transaction.numConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    // Function to get the list of owners
    function getOwers() public view returns(address[] memory){
        return owners;
    }

    // Function to get the total number of transactions
    function getTransactionCount() public view returns(uint){
        return transactions.length;
    }

    // Function to get details of a specific transaction
    function getTx(uint _txIndex) 
        public 
        view 
        returns(
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmation
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
