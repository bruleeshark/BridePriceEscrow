// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract BridePriceEscrow {
    
    address payable public bride;
    address payable public groom;
    address public trustedThirdParty;
    uint public constant MIN_AMOUNT = 1000 ether; // 1,000.0 ETH or greater
    uint public amount;
    bool public weddingConfirmed;
    bool public bridePriceSent;
    bool public groomWithdrawn;
    string public contractDescription;
    
    event WeddingConfirmed();
    event FundsWithdrawn();
    event DescriptionSet(string description);
    
    constructor(address payable _bride, address payable _groom, address _trustedThirdParty, uint _amount) payable {
        require(_amount >= MIN_AMOUNT, "The amount must be 1,000.0 ETH or greater.");
        bride = _bride;
        groom = _groom;
        trustedThirdParty = _trustedThirdParty;
        amount = _amount;
        bridePriceSent = false;
        groomWithdrawn = false;
    }
    
    function confirmWedding() public {
        require(msg.sender == trustedThirdParty, "Only the trusted third party can confirm the wedding.");
        require(weddingConfirmed == false, "The wedding has already been confirmed.");
        weddingConfirmed = true;
        if (bridePriceSent == false) {
            bride.transfer(amount);
            bridePriceSent = true;
        }
        emit WeddingConfirmed();
    }
    
    function withdraw() public payable {
        require((msg.sender == groom || msg.sender == bride), "Only the bride or groom can withdraw the escrowed funds.");
        require(trustedThirdParty != address(0), "The trusted third party has not been set yet.");
        require(weddingConfirmed == true, "The wedding has not been confirmed yet.");
        if (msg.sender == groom) {
            require(groomWithdrawn == false, "The groom has already withdrawn the funds.");
            groomWithdrawn = true;
            groom.transfer(amount);
        } else {
            require(bridePriceSent == true, "The bride price has not been sent yet.");
            require(groomWithdrawn == false, "The groom has already withdrawn the funds.");
            bridePriceSent = false;
            bride.transfer(amount);
        }
        emit FundsWithdrawn();
    }
    
    function setDescription(string memory _description) public {
        require(msg.sender == bride, "Only the bride can set the contract description.");
        contractDescription = _description;
        emit DescriptionSet(_description);
    }
    
    receive() external payable {
        require(msg.sender == groom, "The contract only accepts funds from the groom.");
    }
}
