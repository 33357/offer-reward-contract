//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OfferReward is IOfferReward, Ownable {
    mapping(uint48 => Offer) public offerMap;

    mapping(bytes32 => uint48[]) public tagHash_OfferIdListMap;

    mapping(uint48 => Answer) public answerMap;

    mapping(address => Publisher) public publisherMap;

    uint48 public offerLength = 0;

    uint48 public answerLength = 0;

    uint48 public minFinshTime = 1 days;

    uint48 public feeRate = 500;

    address public feeAddress;

    uint256 public minOfferValue = 0.005 ether;

    uint256 public answerFee = 0.0005 ether;

    constructor() {
        feeAddress = msg.sender;
    }

    /* ================ UTIL FUNCTIONS ================ */

    /* ================ VIEW FUNCTIONS ================ */

    function getTagHash(string calldata tag) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(tag));
    }

    function getOfferList(uint48[] calldata offerIdList) public view override returns (Offer[] memory) {
        Offer[] memory offerList = new Offer[](offerIdList.length);
        for (uint48 i = 0; i < offerIdList.length; i++) {
            offerList[i] = offerMap[offerIdList[i]];
        }
        return offerList;
    }

    function getAnswerList(uint48[] calldata answerIdList) public view override returns (Answer[] memory) {
        Answer[] memory answerList = new Answer[](answerIdList.length);
        for (uint48 i = 0; i < answerIdList.length; i++) {
            answerList[i] = answerMap[answerIdList[i]];
        }
        return answerList;
    }

    function getPublisherList(address[] calldata publisherAddressList)
        public
        view
        override
        returns (Publisher[] memory)
    {
        Publisher[] memory publisherList = new Publisher[](publisherAddressList.length);
        for (uint48 i = 0; i < publisherAddressList.length; i++) {
            publisherList[i] = publisherMap[publisherAddressList[i]];
        }
        return publisherList;
    }

    function getOfferIdListByTagHash(
        bytes32 tagHash,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory offerIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            offerIdList[i] = tagHash_OfferIdListMap[tagHash][start + i];
        }
        return offerIdList;
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        string[] calldata tagList,
        uint48 finishTime
    ) external payable override {
        require(finishTime - block.timestamp >= minFinshTime, "OfferReward: finishTime is too short");
        require(msg.value >= minOfferValue, "OfferReward: value is too low");
        offerLength++;
        offerMap[offerLength] = Offer({
            value: msg.value,
            offerBlock: uint48(block.number),
            finishTime: finishTime,
            publisher: msg.sender,
            answerIdList: new uint48[](0)
        });
        publisherMap[msg.sender].publishOfferAmount++;
        publisherMap[msg.sender].publishOfferValue += msg.value;
        for (uint256 i = 0; i < tagList.length; i++) {
            tagHash_OfferIdListMap[getTagHash(tagList[i])].push(offerLength);
        }
        emit OfferPublished(offerLength, msg.sender, title, content, tagList);
    }

    function publishAnswer(uint48 offerId, string calldata content) external override {
        require(offerId <= offerLength,"OfferReward: offer is not exit");
        answerLength++;
        answerMap[answerLength] = Answer({answerBlock: uint48(block.number), offerId: offerId, publisher: msg.sender});
        offerMap[offerId].answerIdList.push(answerLength);
        publisherMap[msg.sender].publishAnswerAmount++;
        emit AnswerPublished(answerLength, offerId, msg.sender, content);
    }

    function finishOffer(uint48 offerId, uint48 answerId) external {
        require(offerMap[offerId].value > 0, "OfferReward: offer is finished");
        if (answerId == 0) {
            require(block.timestamp >= offerMap[offerId].finishTime, "OfferReward: not over finishTime");
            uint256 feeAmount = offerMap[offerId].answerIdList.length * answerFee;
            if (feeAmount >= offerMap[offerId].value) {
                feeAmount = offerMap[offerId].value;
            }
            uint256 valueAmount = offerMap[offerId].value - feeAmount;
            offerMap[offerId].value = 0;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            if (valueAmount > 0) {
                (success, ) = offerMap[offerId].publisher.call{value: valueAmount}("");
                require(success, "OfferReward: send value failed");
            }
        } else if (answerId > 0) {
            require(offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
            require(answerMap[answerId].offerId == offerId, "OfferReward: not answer");
            require(offerMap[offerId].publisher != answerMap[answerId].publisher, "OfferReward: you are the answer");
            uint256 feeAmount = (offerMap[offerId].value * feeRate) / 10000;
            uint256 rewardAmount = offerMap[offerId].value - feeAmount;
            publisherMap[offerMap[offerId].publisher].rewardOfferAmount++;
            publisherMap[offerMap[offerId].publisher].rewardOfferValue += offerMap[offerId].value;
            publisherMap[answerMap[answerId].publisher].rewardAnswerAmount++;
            publisherMap[answerMap[answerId].publisher].rewardAnswerValue += offerMap[offerId].value;
            offerMap[offerId].value = 0;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            (success, ) = answerMap[answerId].publisher.call{value: rewardAmount}("");
            require(success, "OfferReward: send reward failed");
        }
        emit OfferFinished(offerId);
    }

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content,
        string[] calldata tagList
    ) external override {
        require(offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        offerMap[offerId].offerBlock = uint48(block.number);
        emit OfferPublished(offerId, offerMap[offerId].publisher, title, content, tagList);
    }

    function changeOfferValue(uint48 offerId, uint48 finishTime) external payable override {
        require(offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        require(finishTime >= offerMap[offerId].finishTime, "OfferReward: finishTime can not be less than before");
        if (finishTime > offerMap[offerId].finishTime) {
            offerMap[offerId].finishTime = finishTime;
        }
        if (msg.value > 0) {
            offerMap[offerId].value += msg.value;
        }
    }

    function changeAnswer(uint48 answerId, string calldata content) external override {
        require(answerMap[answerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        answerMap[answerId].answerBlock = uint48(block.number);
        emit AnswerPublished(answerId, answerMap[answerId].offerId, answerMap[answerId].publisher, content);
    }

    /* ================ ADMIN FUNCTIONS ================ */

    function setFeeRate(uint48 newFeeRate) external override onlyOwner {
        feeRate = newFeeRate;
    }

    function setFeeAddress(address newFeeAddress) external override onlyOwner {
        feeAddress = newFeeAddress;
    }

    function setMinOfferValue(uint256 newMinOfferValue) external override onlyOwner {
        minOfferValue = newMinOfferValue;
    }

    function setAnswerFee(uint256 newAnswerFee) external override onlyOwner {
        answerFee = newAnswerFee;
    }

    function setMinFinshTime(uint48 newMinFinshTime) external override onlyOwner {
        minFinshTime = newMinFinshTime;
    }
}
