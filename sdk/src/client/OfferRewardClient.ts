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

  getTagHash(tag: string, config?: CallOverrides): Promise<BytesLike>;

  getOfferList(
    offerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Offer[]>;

  getAnswerList(
    answerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Answer[]>;

  getPublisherList(
    publisherAddressList: string[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Publisher[]>;

  getOfferIdListByTagHash(
    tagHash: BytesLike,
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
