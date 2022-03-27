//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward2.sol";
import "./interfaces/IOfferReward2NFT.sol";

contract OfferReward is IOfferReward2 {
    mapping(uint256 => Offer) public offerMap;

    mapping(uint256 => Answer) public answerMap;

    mapping(uint256 => Publisher) public publisherMap;

    uint256 public offerLength = 1;

    uint256 public answerLength = 1;

    uint256 public minFinshTime = 3 days;

    address public feeAddress;

    uint256 public answerFee = 0.0001 ether;

    uint256 public minOfferValue = 0.002 ether;

    uint256 public maxAnswerAmount = 20;

    uint256 public halfAskAmount = 50;

    IOfferRewardNFT public offerRewardNFT;

    constructor(address offerRewardNFTAddress) {
        offerRewardNFT = IOfferRewardNFT(offerRewardNFTAddress);
        feeAddress = msg.sender;
    }

    /* ================ UTIL FUNCTIONS ================ */

    function _random() internal view returns (uint256) {
        if (offerRewardNFT.tokenAmount() <= halfAskAmount * 2) {
            return halfAskAmount;
        } else {
            uint256 random = (uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, offerLength))) %
                (offerRewardNFT.tokenAmount() - halfAskAmount * 2)) + halfAskAmount;
            return random;
        }
    }

    function _canPublishAnswer(uint256 offerId, uint256 tokenId) internal view returns (bool) {
        if (offerMap[offerId].answerIdList.length < maxAnswerAmount) {
            return true;
        } else if (tokenId >= offerMap[offerId].random && tokenId - offerMap[offerId].random < halfAskAmount) {
            return true;
        } else if (tokenId < offerMap[offerId].random && offerMap[offerId].random - tokenId < halfAskAmount) {
            return true;
        }
        return false;
    }

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        uint256 tokenId,
        string memory description,
        string memory offerUrl,
        uint256 finishTime
    ) external payable {
        require(tokenId != 0 && offerRewardNFT.ownerOf(tokenId) == msg.sender);
        require(finishTime - block.timestamp >= minFinshTime);
        require(msg.value >= minOfferValue);
        offerMap[offerLength] = Offer({
            description: description,
            url: offerUrl,
            value: msg.value,
            publisher: tokenId,
            startTime: block.timestamp,
            finishTime: finishTime,
            random: _random(),
            answerIdList: new uint256[](0),
            finished: false
        });
        publisherMap[tokenId].publishOfferAmount++;
        emit OfferPublished(tokenId, offerLength, msg.value, finishTime);
        offerLength++;
    }

    function publishAnswer(
        uint256 tokenId,
        string memory description,
        uint256 offerId,
        string memory answerUrl
    ) external {
        require(tokenId != 0 && offerRewardNFT.ownerOf(tokenId) == msg.sender);
        require(_canPublishAnswer(offerId, tokenId));
        answerMap[answerLength] = Answer({description: description, url: answerUrl, publisher: tokenId});
        offerMap[offerId].answerIdList.push(answerLength);
        publisherMap[tokenId].publishAnswerAmount++;
        emit AnswerPublished(tokenId, answerLength);
        answerLength++;
    }

    function finishOffer(uint256 offerId) external {
        require(offerRewardNFT.ownerOf(offerMap[offerId].publisher) == msg.sender);
        require(!offerMap[offerId].finished);
        offerMap[offerId].finished = true;
        uint256 feeAmount = offerMap[offerId].answerIdList.length * answerFee;
        (bool success, ) = feeAddress.call{value: feeAmount}("");
        require(success);
        (success, ) = msg.sender.call{value: offerMap[offerId].value - feeAmount}("");
        require(success);
        emit OfferFinished(offerId);
    }

    function rewardAndFinishOffer(uint256 offerId, uint256 offerAnswerId) external {
        require(offerRewardNFT.ownerOf(offerMap[offerId].publisher) == msg.sender);
        require(!offerMap[offerId].finished);
        uint256 answerId = offerMap[offerId].answerIdList[offerAnswerId];
        require(answerId != 0);
        address answerPublisherAddress = offerRewardNFT.ownerOf(answerMap[answerId].publisher);
        require(answerPublisherAddress != address(0));
        offerMap[offerId].finished = true;
        publisherMap[offerMap[offerId].publisher].rewardOfferAmount++;
        publisherMap[answerMap[answerId].publisher].rewardAnswerAmount++;
        if (offerMap[offerId].value > 0) {
            uint256 feeAmount = offerMap[offerId].value / 100;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success);
            uint256 valueAmount = offerMap[offerId].value - feeAmount;
            (success, ) = answerPublisherAddress.call{value: valueAmount}("");
            require(success);
        }
        emit OfferRewardedAndFinished(offerId, offerAnswerId);
    }

    function changeOfferUrl(uint256 offerId, string memory offerUrl) external {
        require(offerRewardNFT.ownerOf(offerMap[offerId].publisher) == msg.sender);
        emit OfferUrlChanged(offerId, offerMap[offerId].url);
        offerMap[offerId].url = offerUrl;
    }

    function changeOfferDescription(uint256 offerId, string memory description) external {
        require(offerRewardNFT.ownerOf(offerMap[offerId].publisher) == msg.sender);
        emit OfferDescriptionChanged(offerId, offerMap[offerId].description);
        offerMap[offerId].description = description;
    }

    function changeAnswerUrl(uint256 answerId, string memory answerUrl) external {
        require(offerRewardNFT.ownerOf(answerMap[answerId].publisher) == msg.sender);
        emit AnswerUrlChanged(answerId, answerMap[answerId].url);
        answerMap[answerId].url = answerUrl;
    }

    function changeAnswerDescription(uint256 answerId, string memory description) external {
        require(offerRewardNFT.ownerOf(answerMap[answerId].publisher) == msg.sender);
        emit AnswerDescriptionChanged(answerId, answerMap[answerId].description);
        answerMap[answerId].description = description;
    }

    /* ================ ADMIN FUNCTIONS ================ */
}
