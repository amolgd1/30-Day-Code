// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized marketplace, 
// where users can buy and sell goods and services without relying on a centralized platform. ****////

pragma solidity 0.8.20;

contract ProductTracking {

    // Struct to define a product
    struct Product {
        address owner;
        string name;
        uint256 price;
        bool available;
    }

    
    address public owner;
    mapping(address => bool) public sellers;
    mapping(address => bool) public sellerApplications;
    mapping(uint => Product) public products;
    uint256 public productCount;

    // Events to track actions on the contract
    event ProductAdded(uint256 productId, address owner, string name, uint price);
    event SellerApplied(address applicant);
    event SellerVerified(address seller);

    // Constructor to initialize the contract with initial sellers
    constructor(address[] memory _initialSellers) {
        owner = msg.sender;
        sellers[msg.sender] = true; // Owner is a default seller

        for (uint256 i = 0; i < _initialSellers.length; i++) {
            sellers[_initialSellers[i]] = true;
        }
    }

    // Modifier to restrict access to the contract owner only
    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can call this function");
        _;
    }

    // Modifier to allow access only to approved sellers
    modifier onlySeller() {
        require(sellers[msg.sender], "You are not a seller, apply to become a seller");
        _;
    }

    // Function for non-sellers to apply for seller status
    function applyForSeller() public {
        require(!sellers[msg.sender], "You are already a seller");
        require(!sellerApplications[msg.sender], "Your application is pending");
        sellerApplications[msg.sender] = true;
        emit SellerApplied(msg.sender);
    }

    // Function for the owner to verify a seller's application
    function verifySeller(address _seller) public onlyOwner {
        require(sellerApplications[_seller], "This address has not applied to become a seller");

        sellers[_seller] = true;
        sellerApplications[_seller] = false;
        emit SellerVerified(_seller);
    }

    // Function for the owner to directly add a seller
    function addSeller(address _newSeller) public {
        require(msg.sender == owner, "Only the owner can add sellers");
        sellers[_newSeller] = true;
    }

    // Function for a seller to add a new product to the marketplace
    function addProduct(string memory _name, uint256 _price) public onlySeller {
        productCount++;
        products[productCount] = Product(msg.sender, _name, _price, true);
        emit ProductAdded(productCount, msg.sender, _name, _price);
    }

    // Function to allow buying a product from the marketplace
    function buyProduct(uint256 _productId) public payable {
        Product storage product = products[_productId];

        require(product.available, "Product is not available");
        require(msg.value >= product.price, "Insufficient balance to buy this product");

        product.available = false;
        address payable seller = payable(product.owner);
        seller.transfer(msg.value);
    }

    // Function to fetch details of a product by its ID
    function productDetails(uint256 _productId) public view returns (address, string memory, uint, bool) {
        Product storage product = products[_productId];
        return (product.owner, product.name, product.price, product.available);
    }
}
