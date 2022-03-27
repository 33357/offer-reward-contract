// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IOfferRewardNFT is IERC721 {
    /* ================ EVENTS ================ */

    event NFTClaimed(address owner, uint256 tokenId);

    /* ================ STRUCTS ================ */



    /* ================ VIEW FUNCTIONS ================ */

    function tokenAmount() external view returns (uint256);

    /* ================ TRANSACTION FUNCTIONS ================ */


    /* ================ ADMIN FUNCTIONS ================ */
}