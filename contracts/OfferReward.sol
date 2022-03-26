//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";

contract OfferReward is IOfferReward {
    mapping(uint256 => Offer) public offerMap;

    mapping(uint256 => Answer) public answerMap;

    mapping(address => Publisher) public publisherMap;

    uint256 public offerLength = 1;

    uint256 public answerLength = 1;

    uint256 public minFinshTime = 3 days;

    address public feeAddress;

    constructor() {
        feeAddress = msg.sender;
    }

    /* ================ UTIL FUNCTIONS ================ */

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string memory description,
        string memory offerUrl,
        uint256 finishTime
    ) external payable {
        require(finishTime - block.timestamp >= minFinshTime);
        offerMap[offerLength] = Offer({
            description: description,
            url: offerUrl,
            value: msg.value,
            publisher: msg.sender,
            finishTime: finishTime,
            answerIdList: new uint256[](0),
            finished: false
        });
        publisherMap[msg.sender].publishOfferNum++;
        emit OfferPublished(msg.sender, offerLength, msg.value, finishTime);
        offerLength++;
    }

    function publishAnswer(
        string memory description,
        uint256 offerId,
        string memory answerUrl
    ) external {
        answerMap[answerLength] = Answer({description: description, url: answerUrl, publisher: msg.sender});
        offerMap[offerId].answerIdList.push(answerLength);
        publisherMap[msg.sender].publishAnswerNum++;
        emit AnswerPublished(msg.sender, answerLength);
        answerLength++;
    }

    function finishOffer(uint256 offerId) external {
        require(offerMap[offerId].publisher == msg.sender);
        require(!offerMap[offerId].finished);
        offerMap[offerId].finished = true;
        if (offerMap[offerId].value > 0) {
            (bool success, ) = msg.sender.call{value: offerMap[offerId].value}("");
            require(success);
        }
        emit OfferFinished(offerId);
    }

    function rewardAndFinishOffer(uint256 offerId, uint256 offerAnswerId) external {
        require(offerMap[offerId].publisher == msg.sender);
        require(!offerMap[offerId].finished);
        uint256 answerId = offerMap[offerId].answerIdList[offerAnswerId];
        require(answerId != 0 && answerMap[answerId].publisher != address(0));
        offerMap[offerId].finished = true;
        publisherMap[msg.sender].rewardOfferNum++;
        publisherMap[answerMap[answerId].publisher].rewardAnswerNum++;
        if (offerMap[offerId].value > 0) {
            uint256 feeAmount = offerMap[offerId].value / 100;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success);
            uint256 valueAmount = offerMap[offerId].value - feeAmount;
            (success, ) = answerMap[answerId].publisher.call{value: valueAmount}("");
            require(success);
        }
        emit OfferRewardedAndFinished(offerId, offerAnswerId);
    }

    function changeOfferUrl(uint256 offerId, string memory offerUrl) external {
        require(offerMap[offerId].publisher == msg.sender);
        emit OfferUrlChanged(offerId, offerMap[offerId].url);
        offerMap[offerId].url = offerUrl;
    }

    function changeOfferDescription(uint256 offerId, string memory description) external {
        require(offerMap[offerId].publisher == msg.sender);
        emit OfferDescriptionChanged(offerId, offerMap[offerId].description);
        offerMap[offerId].description = description;
    }

    function changeAnswerUrl(uint256 answerId, string memory answerUrl) external {
        require(answerMap[answerId].publisher == msg.sender);
        emit AnswerUrlChanged(answerId, answerMap[answerId].url);
        answerMap[answerId].url = answerUrl;
    }

    function changeAnswerDescription(uint256 answerId, string memory description) external {
        require(answerMap[answerId].publisher == msg.sender);
        emit AnswerDescriptionChanged(answerId, answerMap[answerId].description);
        answerMap[answerId].description = description;
    }

    /* ================ ADMIN FUNCTIONS ================ */
}
