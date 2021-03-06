import { CallOverrides, PayableOverrides, BigNumber, Signer, BigNumberish } from 'ethers';
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

  getFirstValueSortOfferId(config?: CallOverrides): Promise<number>;

  getFirstFinishSortOfferId(config?: CallOverrides): Promise<number>;

  getSortLength(config?: CallOverrides): Promise<number>;

  getWaitTime(config?: CallOverrides): Promise<number>;

  getMinOfferTime(config?: CallOverrides): Promise<number>;

  getMaxOfferTime(config?: CallOverrides): Promise<number>;

  getFeeRate(config?: CallOverrides): Promise<number>;

  getFeeAddress(config?: CallOverrides): Promise<string>;

  getMinOfferValue(config?: CallOverrides): Promise<BigNumber>;

  getAnswerFee(config?: CallOverrides): Promise<BigNumber>;

  getBlockSkip(config?: CallOverrides): Promise<number>;

  getOfferLength(config?: CallOverrides): Promise<number>;

  getOfferIdListByValueSort(
    startOfferId: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  getOfferIdListByFinishSort(
    startOfferId: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  getOfferData(
    offerId: number,
    config?: CallOverrides
  ): Promise<OfferRewardModel.OfferData>;

  getPublisherData(
    publisher: string,
    config?: CallOverrides
  ): Promise<OfferRewardModel.PublisherData>;

  getOfferDataList(
    offerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.OfferData[]>;

  getPublisherDataList(
    publisherAddressList: string[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.PublisherData[]>;

  getAnswerBlockListByOffer(
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

  getRewardOfferIdListByPublisher(
    publisher: string,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]>;

  /* ================ TRANSACTION FUNCTIONS ================ */

  publishOffer(
    title: string,
    content: string,
    offerTime: number,
    beforeValueSortOfferId: number,
    beforeFinishSortOfferId: number,
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
    rewarder: string,
    beforeValueSortOfferId: number,
    beforeFinishSortOfferId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferFinishedEvent>;

  changeOfferData(
    offerId: number,
    title: string,
    content: string,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  changeOfferValue(
    offerId: number,
    finishTime: number,
    oldBeforeValueSortOfferId: number,
    oldBeforeFinishSortOfferId: number,
    newBeforeValueSortOfferId: number,
    newBeforeFinishSortOfferId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  /* ================ EVENT FUNCTIONS ================ */

  getOfferPublishedEvent(
    offerId: BigNumberish | undefined,
    from: number,
    to: number
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  getOfferFinishedEvent(
    offerId: BigNumberish | undefined,
    rewarder: string | undefined,
    from: number,
    to: number
  ): Promise<OfferRewardModel.OfferFinishedEvent>;

  getAnswerPublishedEventList(
    offerId: BigNumberish | undefined,
    publisher: string | undefined,
    from: number,
    to: number
  ): Promise<Array<OfferRewardModel.AnswerPublishedEvent>>;

  /* ================ UTILS FUNCTIONS ================ */
}
