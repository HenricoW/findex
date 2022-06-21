import { Principal } from "@dfinity/principal";
import React, { createContext, useContext } from "react";
import { appCanisters } from "../../../pages";
import { getUserAccAmounts, getWalletBalances } from "../utils/helpers";
import { AppContext, AppDispatchContext } from "./Layout";

export const PanelInputCtxt = createContext<(fieldAction: string, value: number) => Promise<void>>(async () => {});

function ContractActions({ children }: { children: React.ReactNode }) {
  const { selectedToken, userData, canisters } = useContext(AppContext);
  const appDispatch = useContext(AppDispatchContext);

  const updateVals = async () => {
    if (canisters) {
      const payload = await getWalletBalances(userData.address, canisters);
      const payload2 = await getUserAccAmounts(userData.appWallet, canisters);
      appDispatch({ type: "setWalletAmts", payload, target: "user" }); // trigger app-wide reload
      appDispatch({ type: "setAccAmts", payload: payload2, target: "user" });
    }
  };

  const onFormSubmit = async (fieldAction: string, val: number) => {
    // console.log(canisters);
    const tckr = selectedToken.ticker;
    if (Object.keys(canisters).length > 0) {
      const uToken = canisters[tckr];
      const fiticker = tckr.startsWith("m") ? tckr.replace("m", "fi") : `fi${tckr}`; // NOTE: for mock and actual tokens
      const fiTokenAddr = appCanisters[fiticker].id;
      const fiToken = canisters[fiticker];
      const ftrl = canisters["fitroller"];

      console.log("field action: ", fieldAction);
      const value = val * Math.pow(10, appCanisters[tckr].tokenDecimals);

      switch (fieldAction) {
        case "deposit":
          console.log("submit value", value);
          uToken.approve(Principal.fromText(fiTokenAddr), value).then(() => {
            fiToken.mintfi(value).then((resp) => console.log(resp));
          });
          break;
        case "withdraw":
          fiToken.redeem(value).then((resp) => console.log(resp));
          break;
        case "borrow":
          ftrl
            .enterMarkets([Principal.fromText(fiTokenAddr)])
            .then((resp) => {
              console.log(resp);
              return fiToken.borrow(value);
            })
            .then((resp) => console.log(resp));
          break;
        case "repay":
          console.log("submit value", value);
          uToken.approve(Principal.fromText(fiTokenAddr), 100 * value).then((resp) => {
            console.log(resp);
            fiToken.repayBehalf(Principal.fromText(userData.appWallet), value).then((resp) => console.log(resp));
          });
          break;
        default:
          return;
      }
      console.log("Updating values");
      await updateVals();
    }
  };

  return (
    <>
      <PanelInputCtxt.Provider value={onFormSubmit}>{children}</PanelInputCtxt.Provider>
    </>
  );
}

export default ContractActions;
