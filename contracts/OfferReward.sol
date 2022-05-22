//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OfferReward is IOfferReward, Ownable {
    mapping(uint48 => Offer) private _offerMap;

    mapping(address => Publisher) private _publisherMap;

    uint48 public offerLength = 0;

    uint48 public minFinshTime = 1 days;

    uint48 public blockSkip = 5000;

    uint48 public feeRate = 500;

    address public feeAddress;

    uint256 public minOfferValue = 0.003 ether;

    uint256 public answerFee = 0.0002 ether;

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
            answerAmount: _offerMap[offerId].answerAmount,
            answerBlockListLength: uint48(_offerMap[offerId].answerBlockList.length)
        });
        return offerData;
    }

    function getPublisherData(address publisher) public view override returns (PublisherData memory) {
        PublisherData memory publisherData = PublisherData({
            offerIdListLength: uint48(_publisherMap[publisher].offerIdList.length),
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

    function getOfferDataList(uint48[] calldata offerIdList) public view override returns (OfferData[] memory) {
        OfferData[] memory offerDataList = new OfferData[](offerIdList.length);
        for (uint48 i = 0; i < offerIdList.length; i++) {
            offerDataList[i] = getOfferData(offerIdList[i]);
        }
        return offerDataList;
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

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
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
            answerAmount: 0,
            answerBlockList: new uint48[](0)
        });
        _publisherMap[msg.sender].publishOfferAmount++;
        _publisherMap[msg.sender].publishOfferValue += msg.value;
        _publisherMap[msg.sender].offerIdList.push(offerLength);
        emit OfferPublished(offerLength, msg.sender, title, content);
    }

    function publishAnswer(uint48 offerId, string calldata content) external override {
        require(offerId <= offerLength, "OfferReward: offer is not exit");
        if (
            _offerMap[offerId].answerBlockList.length == 0 ||
            uint48(block.number) - _offerMap[offerId].answerBlockList[_offerMap[offerId].answerBlockList.length - 1] >
            blockSkip
        ) {
            _offerMap[offerId].answerBlockList.push(uint48(block.number));
        }
        _offerMap[offerId].answerAmount++;
        _publisherMap[msg.sender].publishAnswerAmount++;
        emit AnswerPublished(offerId, msg.sender, content);
    }

    function finishOffer(uint48 offerId, address rewarder) external {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        if (rewarder == address(0)) {
            require(block.timestamp >= _offerMap[offerId].finishTime, "OfferReward: not over finishTime");
            uint256 feeAmount = _offerMap[offerId].answerAmount * answerFee;
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
        } else {
            require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
            require(_offerMap[offerId].publisher != rewarder, "OfferReward: you are the rewarder");
            uint256 feeAmount = (_offerMap[offerId].value * feeRate) / 10000;
            uint256 rewardAmount = _offerMap[offerId].value - feeAmount;
            _publisherMap[_offerMap[offerId].publisher].rewardOfferAmount++;
            _publisherMap[_offerMap[offerId].publisher].rewardOfferValue += _offerMap[offerId].value;
            _publisherMap[rewarder].rewardAnswerAmount++;
            _publisherMap[rewarder].rewardAnswerValue += _offerMap[offerId].value;
            _offerMap[offerId].value = 0;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            (success, ) = rewarder.call{value: rewardAmount}("");
            require(success, "OfferReward: send reward failed");
        }
        emit OfferFinished(offerId);
    }

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content
    ) external override {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        _offerMap[offerId].offerBlock = uint48(block.number);
        emit OfferPublished(offerId, _offerMap[offerId].publisher, title, content);
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

    function setBlockSkip(uint48 newBlockSkip) external override onlyOwner {
        blockSkip = newBlockSkip;
    }
}
