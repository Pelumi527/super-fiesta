//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FusionsByGarvenLabs is ERC721Enumerable, Ownable, Pausable, ReentrancyGuard{

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public baseExtension = ".json";
    string public baseURI;
    string public notRevealedUri;
    bytes32 root = 0x3af020aab4e27a80329d7f7a7616a8c69b2317e8222e6211c2e495322c4a2a89;

    
    uint public maxSupply = 8000;
    uint public maxPublicAmount = 10;
    uint public price = 0.04 ether;
    uint public presalePrice;

    bool public presale;
    bool public isRevealed;

    mapping(address => bool) public isVerified;
    mapping(address => uint) public isAllowedToMintInPresale;
    mapping(address => uint) public maxMintable;
    mapping(address => uint) public preSaleMaxMintAmount;
    mapping(address => uint) public presaleMinted;

   event VStatus(bool status, address _address);


    constructor(string memory name, string memory symbol, string memory initRevealedURI) ERC721(name,symbol){
        setBaseURI(initRevealedURI);
        for(_tokenIds.current(); _tokenIds.current() < 100; _tokenIds.increment()){
            _safeMint(_msgSender(), _tokenIds.current());
        }
        startPresale();
    }


    function mint(uint mintAmount) public payable whenNotPaused() nonReentrant() {
        require(_tokenIds.current() <= maxSupply, "Max amount of NFT minted");
        if(presale == true){
            uint amount = presalePrice * mintAmount;
            require(msg.value >= amount, "inSufficient Funds");
            require(isVerified[msg.sender ] == true,"You are not eligible for presale");
            require(mintAmount <= preSaleMaxMintAmount[msg.sender],"You are not eligible to mint this number of NFT");
            presaleMinted[msg.sender] = presaleMinted[msg.sender] + mintAmount;
            require(presaleMinted[msg.sender] <= preSaleMaxMintAmount[msg.sender], "You cannot mint more than eligible");
            for(uint i = 1; i <= mintAmount; i++ ){
               _safeMint(_msgSender(), _tokenIds.current());
               _tokenIds.increment(); 
            }

        }

        if(presale == false){
            uint amount = price * mintAmount;

            require(msg.value >= amount,"inSufficient Funds");
            require(mintAmount <= maxPublicAmount,"cannot mint more than the amount");

            maxMintable[msg.sender] = maxMintable[msg.sender] + mintAmount;

            require(maxMintable[msg.sender] <= maxPublicAmount,"You cannot mint more than the max NFT allowed");

            for(uint i = 1; i <= mintAmount; i++ ){
               _safeMint(_msgSender(), _tokenIds.current());
               _tokenIds.increment();
            }
        }
    }

    function setRoot(bytes32 newRoot) public onlyOwner returns(bool){
        root = newRoot;
        return true;
    }

    function verification(bytes32[] memory proof, uint maxMintAmount) whenNotPaused() nonReentrant() public  returns(bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        bool verified = MerkleProof.verify(proof, root, leaf);

        if(verified == true){
            isVerified[msg.sender] = true;
            preSaleMaxMintAmount[msg.sender] = maxMintAmount;
        }
        emit VStatus(verified,msg.sender);
        return verified;
    }



    function tokenURI(uint256 tokenId) 
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }


    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function totalMinted() public view returns(uint){
        return _tokenIds.current();
    }

    function startPresale() public onlyOwner returns(bool){
        presale = true;
        return presale;
    }

    function stopPresale() public onlyOwner returns(bool){
        presale = false;
        return presale;
    }

    function whiteListAddress(address[] memory _address) public onlyOwner() returns(bool){
        for(uint i; i < _address.length; i++){
            isVerified[_address[i]] = true;
            preSaleMaxMintAmount[_address[i]] = maxPublicAmount;
        }
        
        return true;
    }
    function pause() public onlyOwner() returns(bool) {
        _pause();
        return true;
    }

    function unPaused() public onlyOwner() returns(bool) {
        _unpause();
        return true;
    }

    function setPrice(uint _newPrice ) public onlyOwner returns(bool){
        price = _newPrice;
        return true;
    }

    function withdraw() public onlyOwner() returns (bool) {
        uint amount = address(this).balance;
       payable(msg.sender).transfer(amount);
       return true;
    }
     function viewRoot() public onlyOwner view returns(bytes32){
         return root;
    }

    function setMaxSupply(uint _maxSupply) public onlyOwner returns(bool){
        maxSupply = _maxSupply;
        return true;
    }

    function setPresalePrice(uint _price) public onlyOwner returns(bool){
        presalePrice = _price;
        return true;
    }

    function setMaxPublicSale(uint amount) public onlyOwner returns(bool){
        maxPublicAmount = amount;
        return true;
    }
} 
