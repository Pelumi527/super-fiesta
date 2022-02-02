//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FusionByGarbleLabs.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheoFunctions is Ownable{

    FusionsByGarvenLabs fusion;
    constructor(address _contractAddress){
        fusion = FusionsByGarvenLabs(_contractAddress);
    }

    function setRoot(bytes32 root) public onlyOwner() returns(bool){
        fusion.setRoot(root);
        return true;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner() returns(bool){
        fusion.setBaseURI(_baseURI);
        return true;
    }

    function startPresale() public onlyOwner() returns(bool){
        fusion.startPresale();
        return true;
    }

    function stopPresale() public onlyOwner() returns(bool){
        fusion.stopPresale();
        return true;
    }

    function whiteListAddress(address[] memory _address) public onlyOwner() returns(bool){
        fusion.whiteListAddress(_address);
        return true;
    }

    function pause() public onlyOwner() returns(bool){
        fusion.pause();
        return true;
    }

    function unpause() public onlyOwner() returns(bool){
        fusion.unPaused();
        return true;
    }

    function setPrice(uint _newPrice) public onlyOwner() returns(bool){
        fusion.setPrice(_newPrice);
        return  true;
    }

    function withdraw() public onlyOwner() returns(bool){
        fusion.withdraw();
        return true;
    }

    function viewRoot() public view onlyOwner() returns(bytes32){
        return fusion.viewRoot();
    }

    function setPresalePrice(uint _price) public onlyOwner() returns(bool){
        fusion.setPresalePrice(_price); 
        return true;
    }

    function setMaxPublicSale(uint amount) public onlyOwner() returns(bool){
        fusion.setMaxPublicSale(amount);
        return true;
    }
}