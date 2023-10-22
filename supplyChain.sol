// SPDX-License-Identifier: MIT

//// **** Write a Solidity function to implement a supply chain management system, 
// where products can be tracked from creation to delivery.  ****////
pragma solidity ^0.8.19;

contract supplyChain {
    address public owner;

    struct Product {
        uint productId;
        string name;
        uint manufacturingDate;
        address owner;
        bool isDelivered;
    }

    mapping(uint => Product) public products;
    uint public productCount = 0;

    event ProductCreated(uint productId, string name, uint manufacturingDate, address owner);
    event ProductDelivered(uint productId);
    event TransferOwnership(uint productId, address previousOwner, address newOwner);
    event ProductUpdated(uint productId, string newName);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier productExists(uint _productId) {
        require(_productId <= productCount, "Product does not exist");
        _;
    }

    modifier notDelivered(uint _productId) {
        require(!products[_productId].isDelivered, "Delivered product cannot be modified");
        _;
    }

    function createProduct(string memory _name) public {
        uint _productId = productCount + 1;
        uint _manufacturingDate = block.timestamp;
        address _owner = msg.sender;

        products[_productId] = Product(_productId, _name, _manufacturingDate, _owner, false);
        productCount++;

        emit ProductCreated(_productId, _name, _manufacturingDate, _owner);
    }

    function transferOwnership(uint _productId, address _newOwner) public onlyOwner productExists(_productId) notDelivered(_productId) {
        Product storage product = products[_productId];

        address _previousOwner = product.owner;
        product.owner = _newOwner;
        emit TransferOwnership(_productId, _previousOwner, _newOwner);
    }

    function markDelivered(uint _productId) public productExists(_productId) notDelivered(_productId) {
        Product storage product = products[_productId];
        require(msg.sender == product.owner, "Only the owner can call this function");

        product.isDelivered = true;
        emit ProductDelivered(_productId);
    }

    function updateProduct(uint _productId, string memory _newName) public onlyOwner productExists(_productId) notDelivered(_productId) {
        Product storage product = products[_productId];

        product.name = _newName;
        emit ProductUpdated(_productId, _newName);
    }

    function getProductOwner(uint _productId) public view productExists(_productId) returns (address) {
        return products[_productId].owner;
    }

    function getProductManufacturingDate(uint _productId) public view productExists(_productId) returns (uint) {
        return products[_productId].manufacturingDate;
    }

    function isProductDelivered(uint _productId) public view productExists(_productId) returns (bool) {
        return products[_productId].isDelivered;
    }
}
