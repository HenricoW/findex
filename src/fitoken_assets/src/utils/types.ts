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
    // rename to user totals and move to user data
    walletAmount: string;
    depositsAmount: string;
    borrowedAmount: string;
    totalDeposits: number;
    totalLoaned: number;
  };
  web3: {
    provider: any;
    signer: any;
  };
  contracts: {
    // [contrName: string]: ethers.Contract;
    [contrName: string]: any;
  } | null;
  isUserConnected: boolean;
  selectedTicker: string;
};
