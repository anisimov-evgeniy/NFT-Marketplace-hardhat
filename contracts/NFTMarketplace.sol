// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721 {
    struct NFT {
        uint256 tokenId;
        string tokenURI;
        address payable owner;
        uint256 price;
        bool forSale;
    }

    uint256 public nextTokenId;
    mapping(uint256 => NFT) public nfts;

    address owner;

    event Minted(uint256 tokenId, string tokenURI, address owner);
    event Listed(uint256 tokenId, uint256 price);
    event Sold(uint256 tokenId, address buyer);

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function mint(string memory _tokenURI) external onlyOwner {
        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        nfts[tokenId] = NFT(tokenId, _tokenURI, payable(msg.sender), 0, false);
        nextTokenId++;
        emit Minted(tokenId, _tokenURI, msg.sender);
    }

    function listForSale(uint256 _tokenId, uint256 _price) external {
        require(ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(_price > 0, "Price should be greater than zero");

        NFT storage nft = nfts[_tokenId];
        nft.price = _price;
        nft.forSale = true;

        emit Listed(_tokenId, _price);
    }

    function buy(uint256 _tokenId) external payable {
        NFT storage nft = nfts[_tokenId];
        require(nft.forSale, "Not for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address payable seller = nft.owner;
        nft.owner = payable(msg.sender);
        nft.forSale = false;
        _transfer(seller, msg.sender, _tokenId);

        seller.transfer(msg.value);

        emit Sold(_tokenId, msg.sender);
    }

    function fetchNFT(uint256 _tokenId) external view returns (NFT memory) {
        return nfts[_tokenId];
    }
}
