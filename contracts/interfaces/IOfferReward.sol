// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward {
    /* ================ EVENTS ================ */

    event OfferPublished(
        uint48 indexed offerId,
        address indexed publisher,
        string title,
        string content,
        string[] tagList
    );

    event AnswerPublished(uint48 indexed answerId, uint48 indexed OfferId, address indexed publisher, string content);

    event OfferFinished(uint256 indexed offerId);

    /* ================ STRUCTS ================ */

    struct Offer {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48[] answerIdList;
    }

    struct Answer {
        uint48 answerBlock;
        uint48 offerId;
        address publisher;
    }

    struct Publisher {
        uint256 publishOfferAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferAmount;
        uint256 rewardOfferValue;
        uint256 publishAnswerAmount;
        uint256 rewardAnswerAmount;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getTagHash(string calldata tag) external pure returns (bytes32);

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        string[] calldata tagList,
        uint48 finishTime
    ) external payable;

    function publishAnswer(uint48 offerId, string calldata content) external;

    function finishOffer(uint48 offerId, uint48 answerId) external;

    function changeOffer(
        uint48 offerId,
        string calldata title,
        string calldata content,
        string[] calldata tagList,
        uint48 finishTime
    ) external payable;

    function changeAnswer(uint48 answerId, string calldata content) external;

    /* ================ ADMIN FUNCTIONS ================ */

    function setFeeRate(uint256 newFeeRate) external;

    function setFeeAddress(address newFeeAddress) external;

    function setMinOfferValue(uint256 newMinOfferValue) external;

    function setAnswerFee(uint256 newAnswerFee) external;

    function setMinFinshTime(uint48 newMinFinshTime) external;
}
