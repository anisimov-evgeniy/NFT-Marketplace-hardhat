// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct NFT {
        uint256 id;
        string uri;
        uint256 price;
        address payable creator;
    }

    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => bool) public listedMap;

    event Minted(uint256 indexed tokenId, address indexed creator, string uri, uint256 price);
    event Bought(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event Listed(uint256 indexed tokenId, uint256 price);

    constructor() ERC721("NFT Marketplace", "NFTM") {}

    function mintNFT(string memory tokenURI, uint256 price) public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        nfts[newItemId] = NFT(newItemId, tokenURI, price, payable(msg.sender));
        listedMap[newItemId] = true;

        emit Minted(newItemId, msg.sender, tokenURI, price);
    }

    function buyNFT(uint256 tokenId) public payable {
        require(listedMap[tokenId], "NFT not listed for sale");
        NFT memory nft = nfts[tokenId];
        require(msg.value >= nft.price, "Insufficient funds");

        address previousOwner = ownerOf(tokenId);
        _transfer(previousOwner, msg.sender, tokenId);
        payable(previousOwner).transfer(msg.value);

        listedMap[tokenId] = false;

        emit Bought(tokenId, msg.sender, nft.price);
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner can list");
        nfts[tokenId].price = price;
        listedMap[tokenId] = true;

        emit Listed(tokenId, price);
    }

    function getAllNFTs() public view returns (NFT[] memory) {
        uint256 totalNFTs = _tokenIds.current();
        NFT[] memory allNFTs = new NFT[](totalNFTs);

        for (uint256 i = 0; i < totalNFTs; i++) {
            uint256 tokenId = i + 1; // Token IDs start from 1
            NFT storage nft = nfts[tokenId];
            allNFTs[i] = nft;
        }

        return allNFTs;
    }
}
