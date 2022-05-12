// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";


contract TomatoCheck is AccessControl {
    bytes32 public constant COMPANY_ROLE = keccak256("COMPANY_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    struct Product {
        uint productID;
        string productName;
        address Provider;
        string Retailer;
        bool isConfirmByRetailer;
    }

    struct ProductDiary{
        uint timestamp;
        string message;
    }

    mapping(uint => ProductDiary[]) public productDairy;

    struct Company {
        address companyAddress;
        string companyName;
    }
    bool public isStopped = false;
    mapping(address => Company) public companies;
    mapping(uint => Product) public products;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    receive() external payable {}

    // Modifiers zone
    modifier checkConfirmByRetailer (uint productID){
        require(products[productID].isConfirmByRetailer == false, "This product already confirmed!");
        _;
    }

    modifier onlyWhenNotStopped {
        require(!isStopped);
        _;
    }

    modifier onlyWhenStopped {
        require(isStopped);
        _;
    }


    // Events zone
    event productEvent(Product product);

    event setCompanyEvent(Company company);

    // Function zone
    function acceptByRetailer (uint productID) external onlyRole(COMPANY_ROLE) checkConfirmByRetailer(productID) onlyWhenNotStopped {
        products[productID].isConfirmByRetailer = true;
        writeProductDairy(productID, "Retailer accept product");
        // updateStatusOnProvider(productID, provider);
        emit productEvent(products[productID]);
    }

    function createProduct(
        uint productID,
        string memory productName,
        address Provider,
        bool isConfirmByRetailer,
        string memory Retailer
    ) external payable onlyRole(COMPANY_ROLE) onlyWhenNotStopped {
        require (msg.value >= 0.0001 ether, "Invalid amount");
            Product memory product = Product(
                productID,
                productName,
                Provider,
                Retailer,
                isConfirmByRetailer
            );
            products[productID] = product;
            emit productEvent(product);
        
    }

    function writeProductDairy(uint _productId, string memory _message) public onlyRole(COMPANY_ROLE) {
        ProductDiary memory diary = ProductDiary(
            block.timestamp,
            _message
        );
        productDairy[_productId].push(diary);
    }

    function getProductDairyByProductID(uint _productId) external view returns(uint){
        return productDairy[_productId].length;
    }

    function isCompany (address _address) external view returns (bool) {
        return hasRole(COMPANY_ROLE, _address);

    }

    function setCompany(
        address companyAddress,
        string memory companyName
    ) external payable onlyWhenNotStopped {
        require(msg.value >= 0.01 ether, "Invalid amount");
        Company memory newCompany = Company (
            companyAddress,
            companyName
        );
        _grantRole(COMPANY_ROLE, companyAddress);
        companies[companyAddress] = newCompany;
        emit setCompanyEvent(newCompany);

    }

    function selfDestruct()
        external
        onlyWhenStopped
        onlyRole(ADMIN_ROLE)
    {
        selfdestruct(payable(msg.sender));
    }

    function stopContract()
        external
        onlyRole(ADMIN_ROLE)
    {
        isStopped = true;
    }

    function resumeContract()
        external
        onlyRole(ADMIN_ROLE)
    {
        isStopped = false;
    }

    function withdraw(uint amount)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(hasRole(ADMIN_ROLE, msg.sender));
        require(address(this).balance >= amount, "Invalid amount");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }
}