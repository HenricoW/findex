import { initAppState } from "../../components/Layout";
import { getTotTokensValue } from "../../utils/helpers";
import { allTokenData, defaultUserAmounts } from "../../utils/initialData";
import { AppStateType, tokenDataType, userDataType } from "../../utils/types";

export const collateralReducer = (
  state: typeof defaultUserAmounts,
  action: { type: string; payload: number; origTotals: { totalDeposits: number; totalLoaned: number } }
) => {
  switch (action.type) {
    case "depositAdd":
      return { ...state, totalDeposits: action.origTotals.totalDeposits + action.payload };
    case "depositSub":
      return { ...state, totalDeposits: action.origTotals.totalDeposits - action.payload };
    case "loanedAdd":
      return { ...state, totalLoaned: action.origTotals.totalLoaned + action.payload };
    case "loanedSub":
      return { ...state, totalLoaned: action.origTotals.totalLoaned - action.payload };
    default:
      return state;
  }
};

export const tokenDataReducer = (state: tokenDataType[], action: { type: string; payload: number[] }) => {
  if (action.payload.length !== state.length) return state;
  let newState: { [key: string]: any }[] = state,
    selector: string;

  switch (action.type) {
    case "setSuppRates":
      selector = "saveRate";
      break;
    case "setBorrRates":
      selector = "borrRate";
      break;
    case "setPrices":
      selector = "price";
      break;
    default:
      return state;
  }

  for (let i = 0; i < state.length; i++) newState[i][selector] = action.payload[i];
  return newState as tokenDataType[];
};

export const getUserAmounts = (userData: userDataType, tknData: tokenDataType) => {
  const uAmounts: { [category: string]: string } = {};
  const uDataSlice: { [category: string]: any } = userData;
  const categories = ["wallet", "borrowed", "deposits"];

  for (let i = 0; i < categories.length; i++)
    uAmounts[categories[i] + "Amount"] = (
      uDataSlice[categories[i]][tknData.ticker] ? uDataSlice[categories[i]][tknData.ticker] : 0
    ).toFixed(tknData.displayDecimals); // check if this tickers value has been set, default to zero

  const totalDeposits = getTotTokensValue(allTokenData, userData.deposits);
  const totalLoaned = getTotTokensValue(allTokenData, userData.borrowed);

  return { ...uAmounts, totalDeposits, totalLoaned };
};

const userReducer = (state: AppStateType, action: { type: string; payload: userDataType }) => {
  let userData: userDataType = state.userData; // default value

  switch (action.type) {
    case "signIn":
      userData = action.payload;
      break;
    case "signOut":
      return { ...state, isUserConnected: false, userData: initAppState.userData, userAmounts: defaultUserAmounts }; // defaults
    case "setWalletAmts":
      userData = { ...state.userData, wallet: action.payload.wallet }; // extract only wallet vals for update
      break;
    case "setAccAmts":
      userData = {
        ...state.userData,
        deposits: action.payload.deposits,
        borrowed: action.payload.borrowed,
      };
      break;
    default:
      return state;
  }

  const uUserAmounts = getUserAmounts(userData, state.selectedToken);
  return { ...state, isUserConnected: true, userData, userAmounts: { ...state.userAmounts, ...uUserAmounts } };
};

const tokenReducer = (state: AppStateType, action: { type: string; payload: string }) => {
  switch (action.type) {
    case "selectToken":
      const selectedTicker = action.payload;
      const tData = allTokenData.find((tkn) => tkn.ticker === selectedTicker);
      const selectedToken = typeof tData === "undefined" ? allTokenData[0] : tData;
      const uUserAmounts = getUserAmounts(state.userData, selectedToken); // set user amounts
      return { ...state, selectedTicker, selectedToken, userAmounts: { ...state.userAmounts, ...uUserAmounts } };
    default:
      return state;
  }
};

const web3Reducer = (state: AppStateType, action: { type: string; payload: { provider: any; signer: any } }) => {
  switch (action.type) {
    case "setWeb3":
      return { ...state, web3: { provider: action.payload.provider, signer: action.payload.signer } };
    case "clearWeb3":
      return { ...state, web3: { provider: null, signer: null } };
    default:
      return state;
  }
};

const contractsReducer = (
  state: AppStateType,
  action: {
    type: string;
    payload: {
      [contrName: string]: any;
    } | null;
  }
) => {
  switch (action.type) {
    case "setContracts":
      return { ...state, contracts: action.payload };
    case "clearContracts":
      return { ...state, contracts: null };
    default:
      return state;
  }
};

export type AppActionType = {
  type: string;
  payload: any;
  target: "user" | "token" | "web3" | "contracts";
};

export const appReducer = (state: AppStateType, action: AppActionType) => {
  switch (action.target) {
    case "user":
      return userReducer(state, { type: action.type, payload: action.payload });
    case "token":
      return tokenReducer(state, { type: action.type, payload: action.payload });
    case "web3":
      return web3Reducer(state, { type: action.type, payload: action.payload });
    case "contracts":
      return contractsReducer(state, { type: action.type, payload: action.payload });
    default:
      return state;
  }
};
