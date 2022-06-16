import { allTokenData } from "./initialData";
import { configInputType, tokenDataType, tokenValues } from "./types";

export const collWarnRate = 0.75;

export const shortAddress = (addr: string) => addr.slice(0, 6) + "..." + addr.slice(-5);

// temp
export const getWalletBalances = async (addr: string, contracts: { [name: string]: any }) => {
  const wallVals: { [tckr: string]: number } = {};
  const tickers = getTickerList();

  // TODO: get user wallet balances

  for (let i = 0; i < tickers.length; i++) {
    wallVals[tickers[i]] = 30 + 7 * i;
  }
  console.log("wallVals: ", wallVals);

  return { wallet: wallVals };
};

export const getUserDepositAmounts = async (accAddr: string, contracts: { [name: string]: any }) => {
  const deposits: { [tckr: string]: number } = {};
  const borrowed: { [tckr: string]: number } = {};
  const tickers = getTickerList();

  // TODO: get user balances

  for (let i = 0; i < tickers.length; i++) {
    deposits[tickers[i]] = 50 + 7 * i;
    borrowed[tickers[i]] = 20 + 8 * i;
  }
  console.log("deposits: ", deposits);
  console.log("borrowed: ", borrowed);

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
          helperText: "Your Account",
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

export const getTokenRates = async (contracts: { [ticker: string]: any }) => {
  // temp
  let supplyRates = [1.23, 2.34];
  let borrowRates = [4.23, 4.34];
  // end temp

  console.log({ supply: supplyRates, borrow: borrowRates });

  return { supply: supplyRates, borrow: borrowRates };
};

export const getTickerList = () => allTokenData.map((tkn) => tkn.ticker);

export const getTknPrices = async () => {
  const cgkoIDs = allTokenData.map((tkn) => tkn.api_id);
  const fmtTkns = cgkoIDs.join("%2C");
  const uri = `https://api.coingecko.com/api/v3/simple/price?ids=${fmtTkns}&vs_currencies=usd`;

  let data: {
    [id: string]: {
      usd: number;
    };
  };

  // TODO: FILTER OUT 'undefined' RESULTS (like XTC)
  try {
    const resp = await fetch(uri);
    data = await resp.json();
    console.log("from CG:", data);
    const prices = cgkoIDs.map((coin_id) => data[coin_id!].usd);

    return prices;
  } catch (err) {
    console.log(err);
    return [];
  }
};
