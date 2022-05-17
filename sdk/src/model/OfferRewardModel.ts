import { BigNumber } from 'ethers';

export interface OfferPublishedEvent {
  offerId: number;
  publisher: string;
  title: string;
  content: string;
  tagList: string[];
}

export interface AnswerPublishedEvent {
  answerId: number;
  offerId: number;
  publisher: string;
  content: string;
}

export interface OfferFinishedEvent {
  offerId: number;
}

export interface Offer {
  value: BigNumber;
  offerBlock: number;
  finishTime: number;
  publisher: string;
  answerIdList: number[];
}

export interface OfferData {
  value: BigNumber;
  offerBlock: number;
  finishTime: number;
  publisher: string;
  answerIdListLength: number;
}

export interface Answer {
  answerBlock: number;
  offerId: number;
  publisher: string;
}

export interface Publisher {
  offerIdList: number[];
  answerIdList: number[];
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
  answerIdListLength: number;
  publishOfferAmount: number;
  rewardOfferAmount: number;
  publishAnswerAmount: number;
  rewardAnswerAmount: number;
  publishOfferValue: BigNumber;
  rewardOfferValue: BigNumber;
  rewardAnswerValue: BigNumber;
}
