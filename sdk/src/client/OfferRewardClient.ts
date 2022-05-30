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

  getOfferLength(config?: CallOverrides): Promise<number>;

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

  /* ================ TRANSACTION FUNCTIONS ================ */

  publishOffer(
    title: string,
    content: string,
    finishTime: number,
    config?: PayableOverrides
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  finishOffer(
    offerId: number,
    rewarder: string,
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
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  /* ================ EVENT FUNCTIONS ================ */

  getOfferPublishedEvent(
    offerId: number | undefined,
    from: number,
    to: number
  ): Promise<OfferRewardModel.OfferPublishedEvent>;

  getAnswerPublishedEventList(
    offerId: number | undefined,
    publisher: string | undefined,
    from: number,
    to: number
  ): Promise<Array<OfferRewardModel.AnswerPublishedEvent>>;

  /* ================ UTILS FUNCTIONS ================ */
}
