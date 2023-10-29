// SPDX-License-Identifier: MIT


/* this is the simplest version of erc1155 standerd nft smart contract, 
  we can make changes according our requirements */
/**
    !                                                            
  ,ad8888ba,        db        88b           d88 88888888888  
 d8"'    `"8b      d88b       888b         d888 88           
d8'               d8'`8b      88`8b       d8'88 88           
88               d8'  `8b     88 `8b     d8' 88 88aaaaa      
88      88888   d8YaaaaY8b    88  `8b   d8'  88 88"""""      
Y8,        88  d8""""""""8b   88   `8b d8'   88 88           
 Y8a.    .a88 d8'        `8b  88    `888'    88 88           
  `"Y88888P" d8'          `8b 88     `8'     88 88888888888  
                                                             
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT1155 is ERC1155, Ownable {
    
  string public name;
  string public symbol;

  mapping(uint => string) public tokenURI;

  constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {
    name = "GameItem";
    symbol = "GAME";
  }

  function mint(address _to, uint _id, uint _amount) external onlyOwner {
    _mint(_to, _id, _amount, "");
  }

  function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
    _mintBatch(_to, _ids, _amounts, "");
  }

  function burn(uint _id, uint _amount) external {
    _burn(msg.sender, _id, _amount);
  }

  function burnBatch(uint[] memory _ids, uint[] memory _amounts) external {
    _burnBatch(msg.sender, _ids, _amounts);
  }

  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

  function withdrawBalance(uint256 amount) public onlyOwner{
     payable(msg.sender).transfer(amount);
  }

}
    