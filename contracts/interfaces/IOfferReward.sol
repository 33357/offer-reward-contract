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

    event AnswerPublished(uint48 indexed answerId, uint48 indexed offerId, address indexed publisher, string content);

    event OfferFinished(uint48 indexed offerId);

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
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getTagHash(string calldata tag) external pure returns (bytes32);

    function batchOffer(uint48[] calldata offerIdList) external view returns (Offer[] memory);

    function batchAnswer(uint48[] calldata answerIdList) external view returns (Answer[] memory);

    function batchPublisher(address[] calldata publisherAddressList) external view returns (Publisher[] memory);

    function batchTagOfferId(
        bytes32 tagHash,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

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
