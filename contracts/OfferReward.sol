//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";

contract OfferReward is IOfferReward {
    mapping(uint256 => string) public offerUrl;

    mapping(uint256 => uint256) public offerValue;

    mapping(uint256 => uint256) public offerFinshTime;

    mapping(uint256 => address) public offerPublisher;

    mapping(uint256 => bool) public offerFinshed;

    mapping(address => uint256) public ownered;

    mapping(uint256 => string) public answerUrl;

    mapping(uint256 => address) public answerPublisher;

    mapping(uint256 => mapping(uint256 => uint256)) public offerAnswerMap;

    mapping(uint256 => uint256) public offerAnswerLength;

    mapping(address => uint256) public publishOfferNum;

    mapping(address => uint256) public rewardOfferNum;

    mapping(address => uint256) public rewardAnswerNum;

    uint256 public offerLength = 1;

    uint256 public answerLength = 1;

    uint256 public minFinshTime = 3 days;

    constructor() {}

    /* ================ UTIL FUNCTIONS ================ */

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(string memory newOfferUrl, uint256 finishTime) external payable {
        require(finishTime - block.timestamp >= minFinshTime);
        offerUrl[offerLength] = newOfferUrl;
        offerValue[offerLength] = msg.value;
        offerPublisher[offerLength] = msg.sender;
        offerFinshTime[offerLength] = finishTime;
        publishOfferNum[msg.sender]++;
        offerLength++;
    }

    function publishAnswer(uint256 offerId, string memory newAnswerUrl) external {
        answerUrl[answerLength] = newAnswerUrl;
        answerPublisher[answerLength] = msg.sender;
        offerAnswerMap[offerId][offerAnswerLength[offerId]] = answerLength;
        answerLength++;
        offerAnswerLength[offerId]++;
    }

    function finishOffer(uint256 offerId) external {
        require(offerPublisher[offerId] == msg.sender);
        require(!offerFinshed[offerId]);
        offerFinshed[offerId] = true;
        if (offerValue[offerId] > 0) {
            (bool success, ) = msg.sender.call{value: offerValue[offerId]}("");
            require(success);
        }
    }

    function rewardAndFinishOffer(uint256 offerId, uint256 offerAnswerId) external {
        require(offerPublisher[offerId] == msg.sender);
        require(!offerFinshed[offerId]);
        uint256 answerId = offerAnswerMap[offerId][offerAnswerId];
        require(answerId != 0 && answerPublisher[answerId] != address(0));
        offerFinshed[offerId] = true;
        rewardOfferNum[msg.sender]++;
        rewardAnswerNum[answerPublisher[answerId]]++;
        if (offerValue[offerId] > 0) {
            (bool success, ) = answerPublisher[answerId].call{value: offerValue[offerId]}("");
            require(success);
        }
    }

    function changeOffer(uint256 offerId, string memory newOfferUrl) external {
        require(offerPublisher[offerId] == msg.sender);
        offerUrl[offerId] = newOfferUrl;
    }

    function changeAnswer(uint256 answerId, string memory newAnswerUrl) external {
        require(answerPublisher[answerId] == msg.sender);
        answerUrl[answerId] = newAnswerUrl;
    }

    /* ================ ADMIN FUNCTIONS ================ */
}
