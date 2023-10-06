// SPDX-License-Identifier: MIT

// Write a Solidity function to check if a given address is a contract or not

pragma solidity >0.5.0 <0.9.0;

// Function to check if an Ethereum address is a contract or an EOA ( exteral own account )
contract AddressChecker {
    function CheckAddress(address account) public view returns (bool) {
        uint256 size;

        // inline assembly to check the size of the code at the given address
        assembly {
            size := extcodesize(account)

        }
        // If the size of the code is greater than 0, it's a contract; otherwise, it's an EOA
        return size > 0;
    }
}
