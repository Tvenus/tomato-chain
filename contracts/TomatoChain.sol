// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoChain is AccessControl, Ownable {
    bytes32 private constant COMPANY_ROLE = keccak256("COMPANY_ROLE");

    struct Product {
        uint productID;
        string productName;
        address Provider;
        string Retailer;
        bool isConfirmByRetailer;
    }
    struct Company {
        address companyAddress;
        string companyName;
    }
    bool public isStopped = false;
    address payable public _owner;
    mapping(address => Company) public companies;
    mapping(uint => Product) public products;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _owner = payable(msg.sender);
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
    function acceptByRetailer (uint productID) external onlyRole(COMPANY_ROLE) checkConfirmByRetailer(productID) onlyWhenNotStopped {
        products[productID].isConfirmByRetailer = true;
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
        if (msg.value == 0.0001 ether) {
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
    }

    function isCompany (address _address) external view returns (bool) {
        if (hasRole(COMPANY_ROLE, _address)) {
            return true;
        } else {
            return false;
        }
    }

    function setCompany(
        address companyAddress,
        string memory companyName
    ) external payable onlyWhenNotStopped {
        if (msg.value == 0.01 ether) {
            Company memory newCompany = Company (
                companyAddress,
                companyName
            );
            _grantRole(COMPANY_ROLE, companyAddress);
            companies[companyAddress] = newCompany;
            emit setCompanyEvent(newCompany);
        } else {
            return;
        }
    }

    function selfDestruct()
        external
        onlyWhenStopped
        onlyOwner
    {
        selfdestruct(_owner);
    }

    function stopContract()
        external
        onlyOwner
    {
        isStopped = true;
    }

    function resumeContract()
        external
        onlyOwner
    {
        isStopped = false;
    }

    function withdraw(uint amount)
        external
        onlyOwner
    {
        (bool success, ) = _owner.call{value: amount}("");
        require(success, "Transfer failed.");
    }
}