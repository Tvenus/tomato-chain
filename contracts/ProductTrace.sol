// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TomatoChain.sol";

contract ProductTrace is TomatoCheck {
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");

    struct CompanyProduct {
        address from;
        address retailer;
        uint productId;
        bytes32 ownerRole;
        bool isApproved;
    }

    mapping(address => mapping(uint => CompanyProduct)) public companyProductMapping;

    event transferProductEvent(address indexed _from, address indexed _to, uint indexed _productId);
    event confirmProductEvent(address indexed _from, address indexed _to, uint indexed _productId);

    constructor() TomatoCheck() {}

    modifier checkHasProduct(uint _productId){
        require(products[_productId].Provider == msg.sender || companyProductMapping[msg.sender][_productId].isApproved
        , "Company don't exists this product!");
        _;
    }

    function transferProduct(address _from, address _to, uint _productId) external payable
    onlyRole(COMPANY_ROLE) checkHasProduct(_productId) {
        require(companyProductMapping[_to][_productId].retailer!=address(0), "The receiving company already exists the product!");
        CompanyProduct memory companyProduct = CompanyProduct(_from,_to,_productId, RETAILER_ROLE, false);
        companyProductMapping[_to][_productId] = companyProduct;
        emit transferProductEvent(_from, _to, _productId);
    }
    
    function confirmProduct(uint _productId) external payable onlyRole(COMPANY_ROLE){
        require(companyProductMapping[msg.sender][_productId].retailer!=address(0) , "The company has not received this product yet!");
        require(!companyProductMapping[msg.sender][_productId].isApproved, "The company already confirm the product!");
        CompanyProduct storage cp=companyProductMapping[msg.sender][_productId];
        cp.isApproved=true;
        emit confirmProductEvent(cp.from,cp.retailer,cp.productId);
    }
}
