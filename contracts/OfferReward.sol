//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OfferReward is IOfferReward, Ownable {
    mapping(uint48 => Offer) private _offerMap;

    mapping(bytes32 => uint48[]) private _tagHash_OfferIdListMap;

    mapping(uint48 => Answer) private _answerMap;

    mapping(address => Publisher) private _publisherMap;

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

    function getOfferData(uint48 offerId) public view override returns (OfferData memory) {
        OfferData memory offerData = OfferData({
            value: _offerMap[offerId].value,
            offerBlock: _offerMap[offerId].offerBlock,
            finishTime: _offerMap[offerId].finishTime,
            publisher: _offerMap[offerId].publisher,
            answerIdListLength: uint48(_offerMap[offerId].answerIdList.length)
        });
        return offerData;
    }

    function getAnswerData(uint48 answerId) public view override returns (Answer memory) {
        return _answerMap[answerId];
    }

    function getPublisherData(address publisher) public view override returns (PublisherData memory) {
        PublisherData memory publisherData = PublisherData({
            offerIdListLength: uint48(_publisherMap[publisher].offerIdList.length),
            answerIdListLength: uint48(_publisherMap[publisher].answerIdList.length),
            publishOfferAmount: _publisherMap[publisher].publishOfferAmount,
            rewardOfferAmount: _publisherMap[publisher].rewardOfferAmount,
            publishAnswerAmount: _publisherMap[publisher].publishAnswerAmount,
            rewardAnswerAmount: _publisherMap[publisher].rewardAnswerAmount,
            publishOfferValue: _publisherMap[publisher].publishOfferValue,
            rewardOfferValue: _publisherMap[publisher].rewardOfferValue,
            rewardAnswerValue: _publisherMap[publisher].rewardAnswerValue
        });
        return (publisherData);
    }

    function getOfferIdListLengthByTagHash(bytes32 tagHash) public view override returns (uint48) {
        return uint48(_tagHash_OfferIdListMap[tagHash].length);
    }

    function getTagHash(string calldata tag) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(tag));
    }

    function getOfferDataList(uint48[] calldata offerIdList) public view override returns (OfferData[] memory) {
        OfferData[] memory offerDataList = new OfferData[](offerIdList.length);
        for (uint48 i = 0; i < offerIdList.length; i++) {
            offerDataList[i] = getOfferData(offerIdList[i]);
        }
        return offerDataList;
    }

    function getAnswerDataList(uint48[] calldata answerIdList) public view override returns (Answer[] memory) {
        Answer[] memory answerDataList = new Answer[](answerIdList.length);
        for (uint48 i = 0; i < answerIdList.length; i++) {
            answerDataList[i] = getAnswerData(answerIdList[i]);
        }
        return answerDataList;
    }

    function getPublisherDataList(address[] calldata publisherAddressList)
        public
        view
        override
        returns (PublisherData[] memory)
    {
        PublisherData[] memory publisherDataList = new PublisherData[](publisherAddressList.length);
        for (uint48 i = 0; i < publisherAddressList.length; i++) {
            publisherDataList[i] = getPublisherData(publisherAddressList[i]);
        }
        return publisherDataList;
    }

    function getOfferIdListByTagHash(
        bytes32 tagHash,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory offerIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            offerIdList[i] = _tagHash_OfferIdListMap[tagHash][start + i];
        }
        return offerIdList;
    }

    function getAnswerIdListByOfferId(
        uint48 offerId,
        uint48 start,
        uint48 length
    ) public view returns (uint48[] memory) {
        uint48[] memory answerIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            answerIdList[i] = _offerMap[offerId].answerIdList[start + i];
        }
        return answerIdList;
    }

    function getOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory offerIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            offerIdList[i] = _publisherMap[publisher].offerIdList[start + i];
        }
        return offerIdList;
    }

    function getAnswerIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory answerIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            answerIdList[i] = _publisherMap[publisher].answerIdList[start + i];
        }
        return answerIdList;
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
        _offerMap[offerLength] = Offer({
            value: msg.value,
            offerBlock: uint48(block.number),
            finishTime: finishTime,
            publisher: msg.sender,
            answerIdList: new uint48[](0)
        });
        _publisherMap[msg.sender].publishOfferAmount++;
        _publisherMap[msg.sender].publishOfferValue += msg.value;
        _publisherMap[msg.sender].offerIdList.push(offerLength);
        for (uint256 i = 0; i < tagList.length; i++) {
            _tagHash_OfferIdListMap[getTagHash(tagList[i])].push(offerLength);
        }
        emit OfferPublished(offerLength, msg.sender, title, content, tagList);
    }

    function publishAnswer(uint48 offerId, string calldata content) external override {
        require(offerId <= offerLength, "OfferReward: offer is not exit");
        answerLength++;
        _answerMap[answerLength] = Answer({answerBlock: uint48(block.number), offerId: offerId, publisher: msg.sender});
        _offerMap[offerId].answerIdList.push(answerLength);
        _publisherMap[msg.sender].publishAnswerAmount++;
        _publisherMap[msg.sender].answerIdList.push(answerLength);
        emit AnswerPublished(answerLength, offerId, msg.sender, content);
    }

    function finishOffer(uint48 offerId, uint48 answerId) external {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        if (answerId == 0) {
            require(block.timestamp >= _offerMap[offerId].finishTime, "OfferReward: not over finishTime");
            uint256 feeAmount = _offerMap[offerId].answerIdList.length * answerFee;
            if (feeAmount >= _offerMap[offerId].value) {
                feeAmount = _offerMap[offerId].value;
            }
            uint256 valueAmount = _offerMap[offerId].value - feeAmount;
            _offerMap[offerId].value = 0;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            if (valueAmount > 0) {
                (success, ) = _offerMap[offerId].publisher.call{value: valueAmount}("");
                require(success, "OfferReward: send value failed");
            }
        } else if (answerId > 0) {
            require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
            require(_answerMap[answerId].offerId == offerId, "OfferReward: not answer");
            require(_offerMap[offerId].publisher != _answerMap[answerId].publisher, "OfferReward: you are the answer");
            uint256 feeAmount = (_offerMap[offerId].value * feeRate) / 10000;
            uint256 rewardAmount = _offerMap[offerId].value - feeAmount;
            _publisherMap[_offerMap[offerId].publisher].rewardOfferAmount++;
            _publisherMap[_offerMap[offerId].publisher].rewardOfferValue += _offerMap[offerId].value;
            _publisherMap[_answerMap[answerId].publisher].rewardAnswerAmount++;
            _publisherMap[_answerMap[answerId].publisher].rewardAnswerValue += _offerMap[offerId].value;
            _offerMap[offerId].value = 0;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            (success, ) = _answerMap[answerId].publisher.call{value: rewardAmount}("");
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
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        _offerMap[offerId].offerBlock = uint48(block.number);
        emit OfferPublished(offerId, _offerMap[offerId].publisher, title, content, tagList);
    }

    function changeOfferValue(uint48 offerId, uint48 finishTime) external payable override {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        require(finishTime >= _offerMap[offerId].finishTime, "OfferReward: finishTime can not be less than before");
        if (finishTime > _offerMap[offerId].finishTime) {
            _offerMap[offerId].finishTime = finishTime;
        }
        if (msg.value > 0) {
            _offerMap[offerId].value += msg.value;
        }
    }

    function changeAnswer(uint48 answerId, string calldata content) external override {
        require(_answerMap[answerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        _answerMap[answerId].answerBlock = uint48(block.number);
        emit AnswerPublished(answerId, _answerMap[answerId].offerId, _answerMap[answerId].publisher, content);
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
