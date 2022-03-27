// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward2 {
    /* ================ EVENTS ================ */

    event OfferPublished(uint256 indexed publisher, uint256 indexed offerId, uint256 value, uint256 finishTime);

    event AnswerPublished(uint256 indexed publisher, uint256 indexed answerId);

    event OfferFinished(uint256 indexed offerId);

    event OfferRewardedAndFinished(uint256 indexed offerId, uint256 offerAnswerId);

    event AnswerUrlChanged(uint256 indexed answerId, string originalUrl);

    event AnswerDescriptionChanged(uint256 indexed answerId, string originalDescription);

    event OfferUrlChanged(uint256 indexed offerId, string originalUrl);

    event OfferDescriptionChanged(uint256 indexed offerId, string originalDescription);

    /* ================ STRUCTS ================ */

    struct Offer {
        string description;
        string url;
        uint256 value;
        uint256 startTime;
        uint256 finishTime;
        uint256 publisher;
        uint256[] answerIdList;
        bool finished;
    }

    struct Answer {
        string description;
        string url;
        uint256 publisher;
    }

    struct Publisher {
        uint256 publishOfferAmount;
        uint256 rewardOfferAmount;
        uint256 rewardOfferValue;
        uint256 publishAnswerAmount;
        uint256 rewardAnswerAmount;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        uint256 tokenId,
        string memory description,
        string memory offerUrl,
        uint256 finishTime
    ) external payable;

    function publishAnswer(
        uint256 tokenId,
        string memory description,
        uint256 offerId,
        string memory answerUrl
    ) external;

    function finishOffer(uint256 offerId) external;

    function rewardAndFinishOffer(uint256 offerId, uint256 answerId) external;

    function changeOfferUrl(uint256 offerId, string memory offerUrl) external;

    function changeOfferDescription(uint256 offerId, string memory description) external;

    function changeAnswerUrl(uint256 answerId, string memory answerUrl) external;

    function changeAnswerDescription(uint256 answerId, string memory description) external;

    /* ================ ADMIN FUNCTIONS ================ */
}