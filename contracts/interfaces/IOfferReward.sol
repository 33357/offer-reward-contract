// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward {
    /* ================ EVENTS ================ */

    event OfferPublished(uint48 indexed offerId, string title, string content);

    event AnswerPublished(uint48 indexed offerId, address indexed publisher, string content);

    event OfferFinished(uint48 indexed offerId, address indexed rewarder, uint256 value);

    /* ================ STRUCTS ================ */

    struct Offer {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerAmount;
        uint48 finishBlock;
        uint48[] answerBlockList;
    }

    struct OfferData {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerAmount;
        uint48 finishBlock;
        uint48 answerBlockListLength;
    }

    struct Publisher {
        uint48[] offerIdList;
        uint48[] rewardOfferIdList;
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
        uint48 rewardOfferIdListLength;
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getOfferIdListByValueSort(uint48 startOfferId, uint48 length) external view returns (uint48[] memory);

    function getOfferIdListByFinishSort(uint48 startOfferId, uint48 length) external view returns (uint48[] memory);

    function getOfferData(uint48 offerId) external view returns (OfferData memory);

    function getPublisherData(address publisher) external view returns (PublisherData memory);

    function getOfferDataList(uint48[] calldata offerIdList) external view returns (OfferData[] memory);

    function getPublisherDataList(address[] calldata publisherAddressList)
        external
        view
        returns (PublisherData[] memory);

    function getAnswerBlockListByOffer(
        uint48 offerId,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getRewardOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        uint48 finishTime,
        uint48 beforeValueSortOfferId,
        uint48 beforeFinishSortOfferId
    ) external payable;

    function publishAnswer(uint48 offerId, string calldata content) external;

    function finishOffer(
        uint48 offerId,
        address rewarder,
        uint48 beforeValueSortOfferId,
        uint48 beforeFinishSortOfferId
    ) external;

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content
    ) external;

    function changeOfferValue(
        uint48 offerId,
        uint48 finishTime,
        uint48 oldBeforeValueSortOfferId,
        uint48 oldBeforeFinishSortOfferId,
        uint48 newBeforeValueSortOfferId,
        uint48 newBeforeFinishSortOfferId
    ) external payable;
}
