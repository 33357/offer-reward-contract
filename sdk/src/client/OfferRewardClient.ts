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

  batchOffer(
    offerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Offer[]>;

  batchAnswer(
    answerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Answer[]>;

  batchPublisher(
    publisherAddressList: string[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Publisher[]>;

  batchTagOfferId(
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

  changeOffer(
    offerId: number,
    title: string,
    content: string,
    tagList: string[],
    finishTime: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  changeAnswer(
    answerId: number,
    content: string,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.AnswerPublishedEvent>;
}
