// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./TomatoChain.sol";

contract ProductTrace is TomatoCheck {
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");

    struct CompanyProduct {
        uint productId;
        bytes32 ownerRole;
        bool isApproved;
    }

    mapping(address => uint[]) public companyProductIdMapping;
    mapping(address => mapping(uint => CompanyProduct)) public companyProductMapping;

    event transferProductEvent(address indexed _from, address indexed _to, uint indexed _productId);

    constructor() TomatoCheck() {}

    modifier checkHasProduct(uint productID){
        require(products[productID].Provider == msg.sender || companyProductMapping[msg.sender][productID].isApproved
        , "Company don't exists this product!");
        _;
    }

    function transferProduct(address _from, address _to, uint _productId) external payable
    onlyRole(COMPANY_ROLE) checkHasProduct(_productId) {
        require(!companyProductMapping[_to][productID].isApproved, "The receiving company already exists the product!");
        CompanyProduct memory companyProduct = CompanyProduct(_productId, RETAILER_ROLE, false);
        companyProductIdMapping[_to].push(_productId);
        companyProductIdMapping[_to][_productId] = companyProduct;
        emit transferProductEvent(_from, _to, _productId);
    }
}