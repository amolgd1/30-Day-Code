// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized energy trading platform,
// where users can buy and sell renewable energy certificates (RECs). ****////


pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract renewableEnergytrading{
    IERC721 public token;

    mapping(uint=>uint) public certificatesForSale;
    mapping(uint=>address) public tokenOwner;

    event Sell(address owner,uint Id, uint price);
    event Buy(address newOwner,uint Id);

    constructor(address _token){
        token = IERC721(_token);
    }

    function putOnSell(uint _Id, uint256 _price) public {
        require(_price > 0,"price must be greater than 0");
        require(token.ownerOf(_Id) == msg.sender, "You dont own this token");
        token.transferFrom(msg.sender, address(this), _Id);
        certificatesForSale[_Id] = _price;
        tokenOwner[_Id] = msg.sender;
        emit Sell(msg.sender, _Id, _price);
    }

    function buyCertificate(uint _Id) public payable{
        require(certificatesForSale[_Id] > 0, "Certificate not available for sale");
        require(msg.value >= certificatesForSale[_Id], "Insufficient funds");

        address tokenSeller = tokenOwner[_Id];
        token.safeTransferFrom(address(this), msg.sender, _Id, "");
        payable(tokenSeller).transfer(msg.value);
        certificatesForSale[_Id] = 0;
        emit Buy(msg.sender, _Id);
    }
}