import { tokenDataType, userDataType } from "./types";

export const allTokenData: tokenDataType[] = [
  {
    ticker: "mWICP",
    api_id: "internet-computer",
    imgUrl: "/ICP.svg",
    principal: "",
    saveRate: 0.0,
    borrRate: 0.0,
    price: 1.0,
    tokenDecimals: 6,
    displayDecimals: 3,
  },
  {
    ticker: "mXTC",
    api_id: "usd-coin",
    imgUrl: "/XTC.jfif",
    principal: "",
    saveRate: 0.0,
    borrRate: 0.0,
    price: 1.0,
    tokenDecimals: 6,
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
    XTC: 0.0,
  },
  borrowed: {
    WICP: 0.0,
    XTC: 0.0,
  },
};
