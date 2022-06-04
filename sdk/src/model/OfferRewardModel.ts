import { BigNumber } from 'ethers';

export interface OfferPublishedEvent {
  hash: string;
  offerId: number;
  title: string;
  content: string;
}

export interface AnswerPublishedEvent {
  hash: string;
  offerId: number;
  publisher: string;
  content: string;
}

export interface OfferFinishedEvent {
  hash: string;
  offerId: number;
  rewarder: string;
  value: BigNumber;
}

export interface Offer {
  value: BigNumber;
  offerBlock: number;
  finishTime: number;
  publisher: string;
  answerAmount: number;
  finishBlock: number;
  answerBlockList: number[];
}


export interface OfferData {
  value: BigNumber;
  offerBlock: number;
  finishTime: number;
  publisher: string;
  finishBlock: number;
  answerBlockListLength: number;
  answerAmount: number;
}

export interface Publisher {
  offerIdList: number[];
  rewardOfferIdList: number[];
  publishOfferAmount: number;
  rewardOfferAmount: number;
  publishAnswerAmount: number;
  rewardAnswerAmount: number;
  publishOfferValue: BigNumber;
  rewardOfferValue: BigNumber;
  rewardAnswerValue: BigNumber;
}

export interface PublisherData {
  offerIdListLength: number;
  rewardOfferIdListLength: number;
  publishOfferAmount: number;
  rewardOfferAmount: number;
  publishAnswerAmount: number;
  rewardAnswerAmount: number;
  publishOfferValue: BigNumber;
  rewardOfferValue: BigNumber;
  rewardAnswerValue: BigNumber;
}
