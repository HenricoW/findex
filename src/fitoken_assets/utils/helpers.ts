import { ActorSubclass } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import { appCanisters } from "../../../pages";
import { allTokenData } from "./initialData";
import { configInputType, tokenDataType, tokenValues } from "./types";

export const collWarnRate = 0.75;

export const shortAddress = (addr: string) => addr.slice(0, 6) + "..." + addr.slice(-5);

export const getWalletBalances = async (addr: string, canisters: { [name: string]: any }) => {
  const wallVals: { [tckr: string]: number } = {};
  const tickers = Object.keys(appCanisters).filter((tckr) => !tckr.startsWith("fi"));

  let balances = [];
  if (Object.keys(canisters).length > 0)
    balances = await Promise.all(tickers.map((ticker) => canisters[ticker].balanceOf(Principal.fromText(addr))));

  for (let i = 0; i < tickers.length; i++)
    wallVals[tickers[i]] = Number(balances[i]) / Math.pow(10, appCanisters[tickers[i]].tokenDecimals);

  return { wallet: wallVals };
};

// temp
export const getUserAccAmounts = async (accAddr: string, canisters: { [name: string]: any }) => {
  const deposits: { [tckr: string]: number } = {};
  const borrowed: { [tckr: string]: number } = {};
  // const tickers = getTickerList();
  const tickers = Object.keys(appCanisters).filter((tckr) => tckr.startsWith("fi"));

  // TODO: get user balances
  let snapshots = [];
  if (Object.keys(canisters).length > 0) {
    try {
      snapshots = await Promise.all(
        tickers.map((ticker) => canisters[ticker].getAccountSnapshot(Principal.fromText(accAddr)))
      );
    } catch (error) {
      console.log(error);
    }
  }

  if (snapshots.length < 1) {
    const zeros = Array(tickers.length).fill(0);
    return { deposits: zeros, borrowed: zeros };
  }

  for (let i = 0; i < tickers.length; i++) {
    const uTicker = tickers[i].replace("fi", "m"); // <====================== NOTE! for mock tokens
    const uDecimals = appCanisters[uTicker].tokenDecimals;

    const fibal = Number(snapshots[i][0]) / Math.pow(10, 8);
    const borrowbal = Number(snapshots[i][1]) / Math.pow(10, uDecimals);
    const exchRate = Number(snapshots[i][2]) / Math.pow(10, 6);

    // deposits[tickers[i]] = fibal * exchRate;
    deposits[uTicker] = fibal * exchRate; // <====================== NOTE! for mock tokens
    // borrowed[tickers[i]] = borrowbal;
    borrowed[uTicker] = borrowbal; // <====================== NOTE! for mock tokens
  }

  return { deposits, borrowed };
};
// end temp

export const getTotTokensValue = (tknData: tokenDataType[], usrValues: tokenValues) => {
  let sum = 0;
  for (let i = 0; i < tknData.length; i++) {
    let tkn = tknData[i];
    if (tkn.ticker in usrValues) sum += tkn.price * usrValues[tkn.ticker];
  }

  return sum;
};

export const getInputConfig = ({ panelType, userAmounts, decimals, price }: configInputType) => {
  const borrowLimit = (userAmounts.totalDeposits * collWarnRate - userAmounts.totalLoaned) / price;
  const decFactor = Math.pow(10, decimals);

  switch (panelType) {
    case "savePanel":
      return {
        btnColor: "green",
        top: {
          title: "Deposit",
          helperText: "Your Wallet",
          helperAmount: userAmounts.walletAmount,
          ethRequest: "deposit",
        },
        bottom: {
          title: "Withdraw",
          helperText: "Savings",
          helperAmount: userAmounts.depositsAmount,
          ethRequest: "withdraw",
        },
      };
    default:
      // "borrowPanel":
      return {
        btnColor: "orange",
        top: {
          title: "Borrow",
          helperText: "Limit",
          helperAmount: (Math.floor(borrowLimit * decFactor) / decFactor).toString(),
          ethRequest: "borrow",
        },
        bottom: {
          title: "Repay",
          helperText: "You Owe",
          helperAmount: userAmounts.borrowedAmount,
          ethRequest: "repay",
        },
      };
  }
};

export const inputDispatchConfig: {
  [panelType: string]: {
    [pos: string]: string;
  };
} = {
  savePanel: {
    top: "depositAdd",
    bottom: "depositSub",
  },
  borrowPanel: {
    top: "loanedAdd",
    bottom: "loanedSub",
  },
};

export const getTokenRates = async (canisters: { [ticker: string]: ActorSubclass }) => {
  // get only fitoken actors
  const tickers = Object.keys(appCanisters).filter((tckr) => tckr.startsWith("fi"));

  // fetch per min rates
  let sRatesPerMin: number[] = [],
    bRatesPerMin: number[] = [];
  if (Object.keys(canisters).length > 0) {
    sRatesPerMin = (await Promise.all(tickers.map((ticker) => canisters[ticker].getSupplyRatePerMin()))) as number[];
    bRatesPerMin = (await Promise.all(tickers.map((ticker) => canisters[ticker].getBorrowRatePerMin()))) as number[];
  }

  // compile results
  const ratesAPY = [...sRatesPerMin, ...bRatesPerMin].map((val) => (Number(val) * 60 * 24 * 365) / 1_000_000);

  // temp
  let supplyRates = [0, 0];
  let borrowRates = [0, 0];
  // end temp
  if (ratesAPY.length > 0) {
    supplyRates = ratesAPY.slice(0, ratesAPY.length / 2);
    borrowRates = ratesAPY.slice(ratesAPY.length / 2);
  }

  return { supply: supplyRates, borrow: borrowRates };
};

export const getTickerList = () => allTokenData.map((tkn) => tkn.ticker);

export const getTknPrices = async () => {
  const fmtTkns = allTokenData.map((tkn) => tkn.api_id).join("%2C");
  const uri = `https://api.coingecko.com/api/v3/simple/price?ids=${fmtTkns}&vs_currencies=usd%2Cxdr`;

  let data: {
    [id: string]: {
      usd: number;
      xdr: number;
    };
  };

  try {
    const resp = await fetch(uri);
    data = await resp.json();
    console.log("from CG:", data);
    const prices = allTokenData.map((tkn) => {
      return tkn.ticker !== "mXTC" ? data[tkn.api_id!].usd : data[tkn.api_id!].usd / data[tkn.api_id!].xdr; // <===== NOTE: for mock token
    });

    return prices;
  } catch (err) {
    console.log(err);
    return [];
  }
};
