//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";

contract OfferReward is IOfferReward {
    mapping(uint48 => Offer) public offerMap;

    mapping(bytes32 => uint48[]) public tagHashMap;

    mapping(uint48 => Answer) public answerMap;

    mapping(address => Publisher) public publisherMap;

    uint48 public offerLength = 0;

    uint48 public answerLength = 0;

    uint256 public minFinshTime = 3 days;

    uint256 public feeRate = 500;

    address public feeAddress;

    uint256 public minOfferValue = 0.005 ether;

    uint256 public answerFee = 0.001 ether;

    constructor() {
        feeAddress = msg.sender;
    }

    /* ================ UTIL FUNCTIONS ================ */

    /* ================ VIEW FUNCTIONS ================ */

    function getTagHash(string calldata tag) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(tag));
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        string[] calldata tagList,
        uint48 finishTime
    ) external payable {
        require(finishTime - block.timestamp >= minFinshTime, "OfferReward: finishTime is too short");
        require(msg.value > minOfferValue, "OfferReward: value is too low");
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
            tagHashMap[getTagHash(tagList[i])].push(offerLength);
        }
        emit OfferPublished(
            offerLength,
            msg.sender,
            title,
            content,
            tagList
        );
    }

    function publishAnswer(uint48 offerId, string calldata content) external {
        answerLength++;
        answerMap[answerLength] = Answer({answerBlock: uint48(block.number), offerId: offerId, publisher: msg.sender});
        offerMap[offerId].answerIdList.push(answerLength);
        publisherMap[msg.sender].publishAnswerAmount++;
        emit AnswerPublished(answerLength, offerId, msg.sender, content);
    }

    function finishOffer(uint48 offerId, uint48 answerId) external {
        require(offerMap[offerId].value > 0, "OfferReward: offer is finished");
        if (answerId == 0) {
            require(block.timestamp > offerMap[offerId].finishTime, "OfferReward: not over finishTime");
            uint256 feeAmount = offerMap[offerId].value - offerMap[offerId].answerIdList.length * answerFee;
            if (feeAmount >= offerMap[offerId].value) {
                offerMap[offerId].value = 0;
                (bool success, ) = feeAddress.call{value: feeAmount}("");
                require(success, "OfferReward: send fee failed");
            } else {
                uint256 valueAmount = offerMap[offerId].value - feeAmount;
                offerMap[offerId].value = 0;
                (bool success, ) = feeAddress.call{value: feeAmount}("");
                require(success, "OfferReward: send fee failed");
                (success, ) = offerMap[offerId].publisher.call{value: valueAmount}("");
                require(success, "OfferReward: send value failed");
            }
        } else if (answerId > 0) {
            require(offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
            require(answerMap[answerId].offerId == offerId, "OfferReward: not answer");
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

    function changeOffer(
        uint48 offerId,
        string calldata title,
        string calldata content,
        string[] calldata tagList,
        uint48 finishTime
    ) external payable {
        require(offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        require(finishTime >= offerMap[offerId].finishTime, "OfferReward: finishTime can not be less than before");
        offerMap[offerId].offerBlock = uint48(block.number);
        if (finishTime > offerMap[offerId].finishTime) {
            offerMap[offerId].finishTime = finishTime;
        }
        if (msg.value > 0) {
            offerMap[offerId].value += msg.value;
        }
        emit OfferPublished(
            offerId,
            offerMap[offerId].publisher,
            title,
            content,
            tagList
        );
    }

    function changeAnswer(uint48 answerId, string calldata content) external {
        require(answerMap[answerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        answerMap[answerId].answerBlock = uint48(block.number);
        emit AnswerPublished(answerId, answerMap[answerId].offerId, answerMap[answerId].publisher, content);
    }

    /* ================ ADMIN FUNCTIONS ================ */
}
