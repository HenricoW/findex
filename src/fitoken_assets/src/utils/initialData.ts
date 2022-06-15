import { tokenDataType, userDataType } from "./types";

export const allTokenData: tokenDataType[] = [
  {
    ticker: "WICP",
    api_id: "internet-computer",
    imgUrl: "/wBTC.svg",
    principal: "0xa1faa15655b0e7b6b6470ed3d096390e6ad93abb",
    saveRate: 0.0,
    borrRate: 0.0,
    price: 52.33,
    tokenDecimals: 6,
    displayDecimals: 4,
  },
  {
    ticker: "XTC",
    api_id: "basic-attention-token",
    imgUrl: "/DAI.svg",
    principal: "0x390e6ad93aa1f470eaa15656bb5b0e7b6b6d3d09",
    saveRate: 0.0,
    borrRate: 0.0,
    price: 1.33,
    tokenDecimals: 8,
    displayDecimals: 3,
  },
];

export const ZERO_ADDR = "0x0000000000000000000000000000000000000000";

export const defaultUserAmounts = {
  walletAmount: "0",
  depositsAmount: "0",
  borrowedAmount: "0",
  totalDeposits: 0,
  totalLoaned: 0,
};

export const userData: userDataType = {
  address: ZERO_ADDR,
  blockie: "/blockie_ex.png",
  appWallet: ZERO_ADDR,
  wallet: {
    WICP: 0.0,
    XTC: 0.0,
  },
  deposits: {
    WICP: 0.0,
    XTC: 0.01,
  },
  borrowed: {
    WICP: 0.0,
    XTC: 0.0,
  },
};
