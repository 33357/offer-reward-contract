//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IOfferReward2NFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract OfferRewardNFT is ERC721, ERC721Enumerable, IOfferRewardNFT {
    uint256 private _tokenAmount = 1;
    string public baseURI;

    constructor() ERC721("OfferRewardNFT", "OfferRewardNFT") {}

    /* ================ UTIL FUNCTIONS ================ */

    function _baseURI() internal view override(ERC721) returns (string memory) {
        return baseURI;
    }

    function _awardNFT(address receiver) internal returns (uint256) {
        uint256 newId = _tokenAmount;
        _tokenAmount++;
        _safeMint(receiver, newId);
        return newId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /* ================ VIEW FUNCTIONS ================ */
    function tokenAmount() external view override returns (uint256) {
        return _tokenAmount;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable,IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function getNFT() external {
        uint256 tokenId = _awardNFT(msg.sender);
        emit NFTClaimed(msg.sender, tokenId);
    }

    /* ================ ADMIN FUNCTIONS ================ */
}
