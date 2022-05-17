import {
  CallOverrides,
  PayableOverrides,
  BigNumber,
  Signer,
  BytesLike
} from 'ethers';
import { Provider } from '@ethersproject/providers';
import { OfferRewardModel } from '../model';

export interface OfferRewardClient {
  connect(
    provider: Provider | Signer,
    address?: string,
    waitConfirmations?: number
  ): Promise<void>;

  address(): string;

  /* ================ VIEW FUNCTIONS ================ */

  getOfferData(
    offerId: number,
    config?: CallOverrides
  ): Promise<OfferRewardModel.OfferData>;

  getAnswerData(
    answerId: number,
    config?: CallOverrides
  ): Promise<OfferRewardModel.Answer>;

  getPublisherData(
    publisher: string,
    config?: CallOverrides
  ): Promise<OfferRewardModel.PublisherData>;

  getOfferIdListLengthByTagHash(
    tagHash: BytesLike,
    config?: CallOverrides
  ): Promise<number>;

  getTagHash(tag: string, config?: CallOverrides): Promise<BytesLike>;

  getOfferDataList(
    offerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.OfferData[]>;

  getAnswerDataList(
    answerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Answer[]>;

  getPublisherDataList(
    publisherAddressList: string[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.PublisherData[]>;

  getOfferIdListByTagHash(
    tagHash: BytesLike,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  getAnswerIdListByOfferId(
    offerId: number,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  getOfferIdListByPublisher(
    publisher: string,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  getAnswerIdListByPublisher(
    publisher: string,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  /* ================ TRANSACTION FUNCTIONS ================ */

  publishOffer(
    title: string,
    content: string,
    tagList: string[],
    finishTime: number,
    config?: PayableOverrides
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  publishAnswer(
    offerId: number,
    content: string,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.AnswerPublishedEvent>;

  finishOffer(
    offerId: number,
    answerId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferFinishedEvent>;

  changeOfferData(
    offerId: number,
    title: string,
    content: string,
    tagList: string[],
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  changeOfferValue(
    offerId: number,
    finishTime: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  changeAnswer(
    answerId: number,
    content: string,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.AnswerPublishedEvent>;

  /* ================ UTILS FUNCTIONS ================ */

  tagHash(tag: string): string;
}
