// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward {
    /* ================ EVENTS ================ */

    /* ================ VIEW FUNCTIONS ================ */


    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(string memory newOfferUrl, uint256 finishTime) external payable;

    function publishAnswer(uint256 offerId, string memory newAnswerUrl) external;

    function finishOffer(uint256 offerId) external;

    function rewardAndFinishOffer(uint256 offerId, uint256 answerId) external;

    function changeOffer(uint256 offerId, string memory newOfferUrl) external;

    function changeAnswer(uint256 answerId, string memory newAnswerUrl) external;

    /* ================ ADMIN FUNCTIONS ================ */
}
