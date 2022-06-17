import { ActorSubclass, HttpAgent } from "@dfinity/agent";
import { defaultUserAmounts } from "./initialData";

export type tokenDataType = {
  ticker: string;
  principal: string;
  saveRate: number;
  borrRate: number;
  price: number;
  tokenDecimals: number;
  displayDecimals: number;
  imgUrl?: string;
  api_id?: string;
};

export type configInputType = {
  panelType: string;
  userAmounts: typeof defaultUserAmounts;
  decimals: number;
  price: number;
};

export type tokenValues = {
  [ticker: string]: number;
};

export type userDataType = {
  address: string;
  blockie: string;
  appWallet: string;
  wallet: tokenValues;
  deposits: tokenValues;
  borrowed: tokenValues;
};

export type AppStateType = {
  userData: userDataType;
  selectedToken: tokenDataType;
  userAmounts: {
    walletAmount: string;
    depositsAmount: string;
    borrowedAmount: string;
    totalDeposits: number;
    totalLoaned: number;
  };
  web3: {
    agent: HttpAgent;
  };
  canisters: {
    [contrName: string]: ActorSubclass; // TODO: REMOVE - NOT NEEDED
  };
  isUserConnected: boolean;
  selectedTicker: string;
};
