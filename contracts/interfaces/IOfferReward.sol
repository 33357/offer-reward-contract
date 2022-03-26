// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward {
    /* ================ EVENTS ================ */

    event OfferPublished(address indexed publisher, uint256 indexed offerId, uint256 value, uint256 finishTime);

    event AnswerPublished(address indexed publisher, uint256 indexed answerId);

    event OfferFinished(uint256 indexed offerId);

    event OfferRewardedAndFinished(uint256 indexed offerId, uint256 offerAnswerId);

    /* ================ STRUCTS ================ */

    struct Offer {
        string description;
        string url;
        uint256 value;
        uint256 finishTime;
        address publisher;
        uint256[] answerIdList;
        bool finished;
    }

    struct Answer {
        string description;
        string url;
        address publisher;
    }

    struct Publisher {
        uint256 publishOfferNum;
        uint256 rewardOfferNum;
        uint256 publishAnswerNum;
        uint256 rewardAnswerNum;
    }

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string memory description,
        string memory offerUrl,
        uint256 finishTime
    ) external payable;

    function publishAnswer(
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
