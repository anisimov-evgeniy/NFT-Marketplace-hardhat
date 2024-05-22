// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721 {
    uint256 private _tokenIdCounter;

    struct Sale {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Sale) public tokenSales;
    uint256[] public tokensForSale;

    address owner;

    constructor() ERC721("ZhendyNFT", "ZNFT") {}

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        _safeMint(to, tokenId);
    }

    function listTokenForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        require(price > 0, "Price must be greater than zero");

        tokenSales[tokenId] = Sale(msg.sender, price);
        tokensForSale.push(tokenId);
        approve(address(this), tokenId);
    }

    function buyToken(uint256 tokenId) public payable {
        Sale memory sale = tokenSales[tokenId];
        require(sale.price > 0, "This token is not for sale");
        require(msg.value >= sale.price, "Insufficient funds");

        address seller = sale.seller;

        // Transfer token to buyer
        _transfer(seller, msg.sender, tokenId);

        // Transfer funds to seller
        payable(seller).transfer(msg.value);

        // Clear the sale
        delete tokenSales[tokenId];

        // Remove token from tokensForSale array
        for (uint256 i = 0; i < tokensForSale.length; i++) {
            if (tokensForSale[i] == tokenId) {
                tokensForSale[i] = tokensForSale[tokensForSale.length - 1];
                tokensForSale.pop();
                break;
            }
        }
    }

    function getTokensForSale() public view returns (uint256[] memory) {
        return tokensForSale;
    }
}
