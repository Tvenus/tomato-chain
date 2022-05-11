// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TomatoChain is AccessControl, Ownable {
    bytes32 private constant COMPANY_ROLE = keccak256("COMPANY_ROLE");

    struct Product {
        uint productID;
        string productName;
        // uint productPrice;
        // string productDescription;
        address Provider;
        string Retailer;
        bool isConfirmByRetailer;
        // string dateOfManufacture;
        // string expirationDate;
        // uint quantity;
    }
    struct Company {
        address companyAddress;
        string companyName;
        // string companyPhoneNumber;
        // string companyEmail;
    }
    bool public isStopped = false;
    address payable public _owner;
    // uint public numberOfCompany;
    // uint public numberOfProduct;
    // mapping(uint => Product) public productByProductId;
    // mapping(string => uint) public totalRetailer;
    // mapping(address => uint) public totalProvider;
    // mapping(string => mapping(uint => Product)) public totalProductRetailer;
    // mapping(address => mapping(uint => Product)) public totalProductProvider;
    // mapping(address => Company) public companies;
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

    // modifier checkProviderOfProduct (uint productID, address sender){
    //     require(productByProductId[productID].Provider == sender, "This product not your!");
    //     _;
    // }

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
    // function getTotalProvider (address provider) external view returns (uint) {
    //     return totalProvider[provider];
    // }

    // function getCompanyInfo (address _address) external view returns (Company memory) {
    //     return companies[_address];
    // }

    function acceptByRetailer (uint productID) external onlyRole(COMPANY_ROLE) checkConfirmByRetailer(productID) onlyWhenNotStopped {
        products[productID].isConfirmByRetailer = true;
        // updateStatusOnProvider(productID, provider);
        emit productEvent(products[productID]);
    }
    // function updateStatusOnProvider (uint productID, address provider) private {
    //     uint _totalProvider = totalProvider[provider];
    //     for (uint i = 0; i <= _totalProvider; i++) {
    //         if (totalProductProvider[provider][i].productID == productID) {
    //             totalProductProvider[provider][i].isConfirmByRetailer = true;
    //         }
    //     }
    // }

    function createProduct(
        uint productID,
        string memory productName,
        // uint productPrice,
        // string memory productDescription,
        address Provider,
        bool isConfirmByRetailer,
        string memory Retailer
        // string memory dateOfManufacture,
        // string memory expirationDate,
        // uint quantity
    ) external payable onlyRole(COMPANY_ROLE) onlyWhenNotStopped {
        if (msg.value == 0.0001 ether) {
            Product memory product = Product(
                productID,
                productName,
                // productPrice,
                // productDescription,
                Provider,
                Retailer,
                isConfirmByRetailer
                // dateOfManufacture,
                // expirationDate,
                // quantity
            );
            // productByProductId[productID] = product;
            // totalRetailer[Retailer]++;
            // totalProvider[Provider]++;
            // numberOfProduct++;
            products[productID] = product;
            // totalProductRetailer[Retailer][totalRetailer[Retailer]] = product;
            // totalProductProvider[Provider][totalProvider[Provider]] = product;
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
        // string memory companyPhoneNumber,
        // string memory companyEmail
    ) external payable onlyWhenNotStopped {
        if (msg.value == 0.01 ether) {
            Company memory newCompany = Company (
                companyAddress,
                companyName
                // companyPhoneNumber,
                // companyEmail
            );
            // companies[companyAddress] = newCompany;
            _grantRole(COMPANY_ROLE, companyAddress);
            // numberOfCompany++;
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