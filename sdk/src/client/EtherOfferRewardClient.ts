import { Provider } from '@ethersproject/providers';
import { BigNumber, CallOverrides, PayableOverrides, Signer } from 'ethers';
import { OfferRewardModel } from 'src/model';
import {
  OfferRewardClient,
  OfferReward,
  OfferReward__factory,
  DeploymentInfo
} from '..';

export class EtherOfferRewardClient implements OfferRewardClient {
  protected _provider: Provider | Signer | undefined;
  protected _waitConfirmations = 1;
  private _contract: OfferReward | undefined;
  private _errorTitle: string | undefined;

  public async connect(
    provider: Provider | Signer,
    address?: string,
    waitConfirmations?: number
  ) {
    this._errorTitle = 'EtherOfferRewardClient';
    if (!address) {
      let chainId;
      if (provider instanceof Signer) {
        chainId = await provider.getChainId();
      } else {
        chainId = (await provider.getNetwork()).chainId;
      }
      if (!DeploymentInfo[chainId]) {
        throw new Error(`${this._errorTitle}: error chain`);
      }
      address = DeploymentInfo[chainId].OfferReward.proxyAddress;
    }
    this._contract = OfferReward__factory.connect(address, provider);
    this._provider = provider;
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
  }

  public address(): string {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.address;
  }

  /* ================ VIEW FUNCTIONS ================ */

  getFirstValueSortOfferId(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.firstValueSortOfferId({ ...config });
  }

  getFirstFinishSortOfferId(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.firstFinishSortOfferId({ ...config });
  }

  getSortLength(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.sortLength({ ...config });
  }

  getMinOfferTime(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.minOfferTime({ ...config });
  }

  getMaxOfferTime(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.maxOfferTime({ ...config });
  }

  getWaitTime(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.waitTime({ ...config });
  }

  getFeeRate(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.feeRate({ ...config });
  }

  getFeeAddress(config?: CallOverrides): Promise<string> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.feeAddress({ ...config });
  }

  getMinOfferValue(config?: CallOverrides): Promise<BigNumber> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.minOfferValue({ ...config });
  }

  getAnswerFee(config?: CallOverrides): Promise<BigNumber> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.answerFee({ ...config });
  }

  getBlockSkip(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.blockSkip({ ...config });
  }

  getOfferLength(config?: CallOverrides): Promise<number> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.offerLength({ ...config });
  }

  getOfferIdListByValueSort(
    startOfferId: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferIdListByValueSort(startOfferId, length, {
      ...config
    });
  }

  getOfferIdListByFinishSort(
    startOfferId: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferIdListByFinishSort(startOfferId, length, {
      ...config
    });
  }

  getOfferData(
    offerId: number,
    config?: CallOverrides
  ): Promise<OfferRewardModel.OfferData> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferData(offerId, { ...config });
  }

  getPublisherData(
    publisher: string,
    config?: CallOverrides
  ): Promise<OfferRewardModel.PublisherData> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getPublisherData(publisher, { ...config });
  }

  getOfferDataList(
    offerIdList: number[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.OfferData[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferDataList(offerIdList, { ...config });
  }

  getPublisherDataList(
    publisherAddressList: string[],
    config?: CallOverrides
  ): Promise<OfferRewardModel.PublisherData[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getPublisherDataList(publisherAddressList, {
      ...config
    });
  }

  getAnswerBlockListByOffer(
    offerId: number,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getAnswerBlockListByOffer(offerId, start, length, {
      ...config
    });
  }

  getOfferIdListByPublisher(
    publisher: string,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getOfferIdListByPublisher(publisher, start, length, {
      ...config
    });
  }

  getRewardOfferIdListByPublisher(
    publisher: string,
    start: number,
    length: number,
    config?: CallOverrides
  ): Promise<number[]> {
    if (!this._contract) {
      throw new Error(`${this._errorTitle}: no contract`);
    }
    return this._contract.getRewardOfferIdListByPublisher(
      publisher,
      start,
      length,
      {
        ...config
      }
    );
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  async publishOffer(
    title: string,
    content: string,
    offerTime: number,
    beforeValueSortOfferId: number,
    beforeFinishSortOfferId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent> {
    if (!this._contract || this._provider instanceof Provider) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract.estimateGas.publishOffer(
      title,
      content,
      offerTime,
      beforeValueSortOfferId,
      beforeFinishSortOfferId,
      {
        ...config
      }
    );
    const transaction = await this._contract.publishOffer(
      title,
      content,
      offerTime,
      beforeValueSortOfferId,
      beforeFinishSortOfferId,
      {
        gasLimit: gas.mul(13).div(10),
        ...config
      }
    );
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
    if (!this._contract || this._provider instanceof Provider) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract.estimateGas.publishAnswer(
      offerId,
      content,
      {
        ...config
      }
    );
    const transaction = await this._contract.publishAnswer(offerId, content, {
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
    rewarder: string,
    beforeValueSortOfferId: number,
    beforeFinishSortOfferId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferFinishedEvent> {
    if (!this._contract || this._provider instanceof Provider) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract.estimateGas.finishOffer(
      offerId,
      rewarder,
      beforeValueSortOfferId,
      beforeFinishSortOfferId,
      {
        ...config
      }
    );
    const transaction = await this._contract.finishOffer(
      offerId,
      rewarder,
      beforeValueSortOfferId,
      beforeFinishSortOfferId,
      {
        gasLimit: gas.mul(13).div(10),
        ...config
      }
    );
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
    config?: PayableOverrides,
    callback?: Function
  ): Promise<OfferRewardModel.OfferPublishedEvent> {
    if (!this._contract || this._provider instanceof Provider) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract.estimateGas.changeOfferData(
      offerId,
      title,
      content,
      {
        ...config
      }
    );
    const transaction = await this._contract.changeOfferData(
      offerId,
      title,
      content,
      {
        gasLimit: gas.mul(13).div(10),
        ...config
      }
    );
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
    offerTime: number,
    oldBeforeValueSortOfferId: number,
    oldBeforeFinishSortOfferId: number,
    newBeforeValueSortOfferId: number,
    newBeforeFinishSortOfferId: number,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    if (!this._contract || this._provider instanceof Provider) {
      throw new Error(`${this._errorTitle}: no singer`);
    }
    const gas = await this._contract.estimateGas.changeOfferValue(
      offerId,
      offerTime,
      oldBeforeValueSortOfferId,
      oldBeforeFinishSortOfferId,
      newBeforeValueSortOfferId,
      newBeforeFinishSortOfferId,
      {
        ...config
      }
    );
    const transaction = await this._contract.changeOfferValue(
      offerId,
      offerTime,
      oldBeforeValueSortOfferId,
      oldBeforeFinishSortOfferId,
      newBeforeValueSortOfferId,
      newBeforeFinishSortOfferId,
      {
        gasLimit: gas.mul(13).div(10),
        ...config
      }
    );
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
  }

  /* ================ EVENT FUNCTIONS ================ */

  async getOfferPublishedEvent(
    offerId: number | undefined,
    from: number,
    to: number
  ): Promise<OfferRewardModel.OfferPublishedEvent> {
    if (!this._contract) {
      return Promise.reject('need to connect a valid provider');
    }
    const res = await this._contract.queryFilter(
      this._contract.filters.OfferPublished(offerId),
      from,
      to
    );
    const offerPublishedEvent: OfferRewardModel.OfferPublishedEvent = {
      hash: res[0].transactionHash,
      offerId: res[0].args[0],
      title: res[0].args[1],
      content: res[0].args[2]
    };
    return offerPublishedEvent;
  }

  async getOfferFinishedEvent(
    offerId: number | undefined,
    rewarder: string | undefined,
    from: number,
    to: number
  ): Promise<OfferRewardModel.OfferFinishedEvent> {
    if (!this._contract) {
      return Promise.reject('need to connect a valid provider');
    }
    const res = await this._contract.queryFilter(
      this._contract.filters.OfferFinished(offerId, rewarder),
      from,
      to
    );
    const offerFinishedEvent: OfferRewardModel.OfferFinishedEvent = {
      hash: res[0].transactionHash,
      offerId: res[0].args[0],
      rewarder: res[0].args[1],
      value: res[0].args[2]
    };
    return offerFinishedEvent;
  }

  async getAnswerPublishedEventList(
    offerId: number | undefined,
    publisher: string | undefined,
    from: number,
    to: number
  ): Promise<Array<OfferRewardModel.AnswerPublishedEvent>> {
    if (!this._contract) {
      return Promise.reject('need to connect a valid provider');
    }
    const res = await this._contract.queryFilter(
      this._contract.filters.AnswerPublished(
        offerId ? BigNumber.from(offerId) : undefined,
        publisher
      ),
      from,
      to
    );
    const events: Array<OfferRewardModel.AnswerPublishedEvent> = [];
    res.forEach(messageCreatedEventList => {
      events.push({
        hash: messageCreatedEventList.transactionHash,
        offerId: messageCreatedEventList.args[0],
        publisher: messageCreatedEventList.args[1],
        content: messageCreatedEventList.args[2]
      });
    });
    return events;
  }

  /* ================ UTILS FUNCTIONS ================ */
}
