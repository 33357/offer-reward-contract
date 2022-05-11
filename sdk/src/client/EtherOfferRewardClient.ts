import { Provider } from '@ethersproject/providers';
import {
  BigNumber,
  utils,
  BytesLike,
  CallOverrides,
  PayableOverrides,
  Signer
} from 'ethers';
import { OfferRewardModel } from 'src/model';
import {
  OfferRewardClient,
  OfferReward,
  OfferReward__factory,
  DeploymentInfo
} from '..';

export class EtherOfferRewardClient implements OfferRewardClient {
  protected _provider: Provider | Signer | undefined;
  protected _waitConfirmations = 3;
  private _contract: OfferReward | undefined;
  private _errorTitle: string | undefined;

  public async connect(
    provider: Provider | Signer,
    address?: string,
    waitConfirmations?: number
  ) {
    this._errorTitle = 'EtherOfferRewardClient';
    if (!address) {
      let network;
      if (provider instanceof Signer) {
        if (provider.provider) {
          network = await provider.provider.getNetwork();
        }
      } else {
        network = await provider.getNetwork();
      }
      if (!network) {
        throw new Error(`${this._errorTitle}: no provider`);
      }
      if (!DeploymentInfo[network.chainId]) {
        throw new Error(`${this._errorTitle}: error chain`);
      }
      address = DeploymentInfo[network.chainId].OfferReward.proxyAddress;
    }
    this._contract = OfferReward__factory.connect(address, provider);
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
  }

  public address(): string {
    if (!this._provider || !this._contract) {
      throw new Error(`${this._errorTitle}: no provider`);
    }
    return this._contract.address;
  }

  /* ================ VIEW FUNCTIONS ================ */

  getTagHash(tag: string, config?: CallOverrides): Promise<BytesLike> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getTagHash(tag, { ...config });
  }

  getOfferList(
    offerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Offer[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferList(offerIdList, { ...config });
  }

  getAnswerList(
    answerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Answer[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getAnswerList(answerIdList, { ...config });
  }

  getPublisherList(
    publisherAddressList: string[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.Publisher[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getPublisherList(publisherAddressList, { ...config });
  }

  getOfferIdListByTagHash(
    tagHash: BytesLike,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferIdListByTagHash(tagHash, start, length, {
      ...config
    });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  async publishOffer(
    title: string,
    content: string,
    tagList: string[],
    finishTime: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent> {
    if (
      !this._provider ||
      !this._contract ||
      this._provider instanceof Provider
    ) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract
      .connect(this._provider)
      .estimateGas.publishOffer(title, content, tagList, finishTime, {
        ...config
      });
    const transaction = await this._contract
      .connect(this._provider)
      .publishOffer(title, content, tagList, finishTime, {
        gasLimit: gas.mul(13).div(10),
        ...config
      });
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
    let messageCreatedEvent: OfferRewardModel.OfferPublishedEvent | undefined;
    if (receipt.events) {
      receipt.events
        .filter(event => event.event === 'OfferPublished' && event.args)
        .map(event => {
          messageCreatedEvent = event.args as any;
        });
    }
    if (!messageCreatedEvent) {
      throw new Error('no event');
    }
    return messageCreatedEvent;
  }

  async publishAnswer(
    offerId: number,
    content: string,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.AnswerPublishedEvent> {
    if (
      !this._provider ||
      !this._contract ||
      this._provider instanceof Provider
    ) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract
      .connect(this._provider)
      .estimateGas.publishAnswer(offerId, content, {
        ...config
      });
    const transaction = await this._contract
      .connect(this._provider)
      .publishAnswer(offerId, content, {
        gasLimit: gas.mul(13).div(10),
        ...config
      });
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
    let messageCreatedEvent: OfferRewardModel.AnswerPublishedEvent | undefined;
    if (receipt.events) {
      receipt.events
        .filter(event => event.event === 'AnswerPublished' && event.args)
        .map(event => {
          messageCreatedEvent = event.args as any;
        });
    }
    if (!messageCreatedEvent) {
      throw new Error('no event');
    }
    return messageCreatedEvent;
  }

  async finishOffer(
    offerId: number,
    answerId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferFinishedEvent> {
    if (
      !this._provider ||
      !this._contract ||
      this._provider instanceof Provider
    ) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract
      .connect(this._provider)
      .estimateGas.finishOffer(offerId, answerId, {
        ...config
      });
    const transaction = await this._contract
      .connect(this._provider)
      .finishOffer(offerId, answerId, {
        gasLimit: gas.mul(13).div(10),
        ...config
      });
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
    let messageCreatedEvent: OfferRewardModel.OfferFinishedEvent | undefined;
    if (receipt.events) {
      receipt.events
        .filter(event => event.event === 'OfferFinished' && event.args)
        .map(event => {
          messageCreatedEvent = event.args as any;
        });
    }
    if (!messageCreatedEvent) {
      throw new Error('no event');
    }
    return messageCreatedEvent;
  }

  async changeOfferData(
    offerId: number,
    title: string,
    content: string,
    tagList: string[],
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent> {
    if (
      !this._provider ||
      !this._contract ||
      this._provider instanceof Provider
    ) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract
      .connect(this._provider)
      .estimateGas.changeOfferData(offerId, title, content, tagList, {
        ...config
      });
    const transaction = await this._contract
      .connect(this._provider)
      .changeOfferData(offerId, title, content, tagList, {
        gasLimit: gas.mul(13).div(10),
        ...config
      });
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
    let messageCreatedEvent: OfferRewardModel.OfferPublishedEvent | undefined;
    if (receipt.events) {
      receipt.events
        .filter(event => event.event === 'OfferPublished' && event.args)
        .map(event => {
          messageCreatedEvent = event.args as any;
        });
    }
    if (!messageCreatedEvent) {
      throw new Error('no event');
    }
    return messageCreatedEvent;
  }

  async changeOfferValue(
    offerId: number,
    finishTime: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    if (
      !this._provider ||
      !this._contract ||
      this._provider instanceof Provider
    ) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract
      .connect(this._provider)
      .estimateGas.changeOfferValue(offerId, finishTime, {
        ...config
      });
    const transaction = await this._contract
      .connect(this._provider)
      .changeOfferValue(offerId, finishTime, {
        gasLimit: gas.mul(13).div(10),
        ...config
      });
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
  }

  async changeAnswer(
    answerId: number,
    content: string,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.AnswerPublishedEvent> {
    if (
      !this._provider ||
      !this._contract ||
      this._provider instanceof Provider
    ) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract
      .connect(this._provider)
      .estimateGas.changeAnswer(answerId, content, {
        ...config
      });
    const transaction = await this._contract
      .connect(this._provider)
      .changeAnswer(answerId, content, {
        gasLimit: gas.mul(13).div(10),
        ...config
      });
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
    let messageCreatedEvent: OfferRewardModel.AnswerPublishedEvent | undefined;
    if (receipt.events) {
      receipt.events
        .filter(event => event.event === 'AnswerPublished' && event.args)
        .map(event => {
          messageCreatedEvent = event.args as any;
        });
    }
    if (!messageCreatedEvent) {
      throw new Error('no event');
    }
    return messageCreatedEvent;
  }

  /* ================ UTILS FUNCTIONS ================ */

  tagHash(tag: string): string {
    return utils.solidityKeccak256(['string'], [tag]);
  }
}
