// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

// [0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db],2
// [0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,0x617F2E2fD72FD9D5503197092aC168c91465E7f2],1
contract MultiSig {
    // An array to store the addresses of the contract owners.
    address[] public owners;

    // The number of owner confirmations required for a transaction.
    uint256 public numConfirmationRequired;

    struct Transaction {
        // The target address for the transaction.
        address to;
        // The amount in wei to be transferred.
        uint256 value;
        // A flag indicating whether the transaction has been executed.
        bool executed;
    }

    // Mapping to keep track of whether each owner has confirmed a transaction.
    mapping(uint256 => mapping(address => bool)) isConfirmed;

    // Array to store pending transactions.
    Transaction[] public transactions;

    event TransactionSubmitted(
        uint256 transactionsId,
        address sender,
        address receiver,
        uint256 amount
    );
    event TransactionConfirmed(uint256 transactionsId);
    event TransactionExecuted(uint256 transactionsId);

    constructor(address[] memory _owners, uint256 _numConfirmationRequired) {
        // Ensure there are more than one owner and numConfirmationRequired is valid.
        require(_owners.length > 1, "Owners required must be greater than 1");
        require(
            _numConfirmationRequired > 0 &&
                _numConfirmationRequired <= _owners.length,
            "Number of confirmations not in sync with the number of owners"
        );

        // Initialize the owners array with the provided addresses.
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }

    modifier OnlyOwner() {
        bool isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "you are not the owner");
        _;
    }

    // Function to deposit funds into the contract.
    function deposit() public payable {}

    function AddNewOwners(
        address[] memory _newOwners,
        uint256 _addNumberOfConfirmationRequired
    ) external OnlyOwner {
        require(_newOwners.length > 0, "Invalid owners");
        require(
            _addNumberOfConfirmationRequired == _newOwners.length,
            "Invalid number of confirmation"
        );

        for (uint256 i = 0; i < _newOwners.length; i++) {
            require(
                _newOwners[i] != address(0),
                "New owner address can't be zero"
            );
            require(
                !isDuplicateOwner(_newOwners[i]),
                "New owner address is already an owner"
            );
            owners.push(_newOwners[i]);
        }

        numConfirmationRequired += _addNumberOfConfirmationRequired;
    }

    function isDuplicateOwner(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // Function to submit a new transaction.
    function submitTransaction(address _to, uint256 _value) public payable {
        // Convert the value to wei and validate the target address and amount.
        uint256 value = _value * 1 ether;
        require(_to != address(0), "Invalid Address");
        require(value > 0, "Transfer amount must be greater than zero");
        uint256 transactionsId = transactions.length;

        // Create and store the new transaction.
        transactions.push(
            Transaction({to: _to, value: value, executed: false})
        );
        emit TransactionSubmitted(transactionsId, msg.sender, _to, value);
    }

    // Function for an owner to confirm a transaction.
    function confirmTransaction(uint256 _transactionsId) public OnlyOwner {
        // Ensure the transaction ID is valid and not already confirmed.
        require(_transactionsId < transactions.length, "Invalid TransactionId");
        require(
            !isConfirmed[_transactionsId][msg.sender],
            "Transaction Already Confirmed"
        );

        // Mark the owner's confirmation and emit the confirmation event.
        isConfirmed[_transactionsId][msg.sender] = true;
        emit TransactionConfirmed(_transactionsId);

        // If the transaction is confirmed by enough owners, execute it.
        if (isTransactionConfirmed(_transactionsId)) {
            executeTransaction(_transactionsId);
        }
    }

    // Function to execute a confirmed transaction.
    function executeTransaction(uint256 _transactionsId)
        public
        payable
        OnlyOwner
    {
        // Ensure the transaction ID is valid and the transaction is not already executed.
        require(_transactionsId < transactions.length, "Invalid TransactionId");
        require(
            !transactions[_transactionsId].executed,
            "Transaction already executed"
        );

        // Mark the transaction as executed and attempt the transfer.
        transactions[_transactionsId].executed = true;
        (bool success, ) = transactions[_transactionsId].to.call{
            value: transactions[_transactionsId].value
        }("");
        require(success, "Transaction execution failed");

        // Emit the execution event.
        emit TransactionExecuted(_transactionsId);
    }

    // Function to check if a transaction is confirmed by the required number of owners.
    function isTransactionConfirmed(uint256 _transactionsId)
        internal
        view
        returns (bool)
    {
        // Ensure the transaction ID is valid.
        require(_transactionsId < transactions.length, "Invalid TransactionId");
        uint256 confirmationCount; // Initially will be zero

        // Count the number of owner confirmations for the transaction.
        for (uint256 i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionsId][owners[i]]) {
                confirmationCount++;
            }
        }
        return confirmationCount >= numConfirmationRequired;
    }
}
