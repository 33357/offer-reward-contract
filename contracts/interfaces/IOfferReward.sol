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

    struct OfferData {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerIdListLength;
    }

    struct Answer {
        uint48 answerBlock;
        uint48 offerId;
        address publisher;
    }

    struct Publisher {
        uint48[] offerIdList;
        uint48[] answerIdList;
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    struct PublisherData {
        uint48 offerIdListLength;
        uint48 answerIdListLength;
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */
    function getOfferData(uint48 offerId) external view returns (OfferData memory);

    function getAnswerData(uint48 answerId) external view returns (Answer memory);

    function getPublisherData(address publisher) external view returns (PublisherData memory);

    function getOfferIdListLengthByTagHash(bytes32 tagHash) external view returns (uint48);

    function getTagHash(string calldata tag) external pure returns (bytes32);

    function getOfferDataList(uint48[] calldata offerIdList) external view returns (OfferData[] memory);

    function getAnswerDataList(uint48[] calldata answerIdList) external view returns (Answer[] memory);

    function getPublisherDataList(address[] calldata publisherAddressList)
        external
        view
        returns (PublisherData[] memory);

    function getOfferIdListByTagHash(
        bytes32 tagHash,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getAnswerIdListByOfferId(
        uint48 offerId,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getAnswerIdListByPublisher(
        address publisher,
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

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content,
        string[] calldata tagList
    ) external;

    function changeOfferValue(uint48 offerId, uint48 finishTime) external payable;

    function changeAnswer(uint48 answerId, string calldata content) external;

    /* ================ ADMIN FUNCTIONS ================ */

    function setFeeRate(uint48 newFeeRate) external;

    function setFeeAddress(address newFeeAddress) external;

    function setMinOfferValue(uint256 newMinOfferValue) external;

    function setAnswerFee(uint256 newAnswerFee) external;

    function setMinFinshTime(uint48 newMinFinshTime) external;
}
