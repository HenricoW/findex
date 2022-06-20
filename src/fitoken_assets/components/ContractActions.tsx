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

  const onFormSubmit = async (fieldAction: string, value: number) => {
    // console.log(canisters);
    const tckr = selectedToken.ticker;
    if (Object.keys(canisters).length > 0) {
      const uToken = canisters[`m${tckr}`];
      const fiTokenAddr = appCanisters[`fi${tckr}`].id;
      const fiToken = canisters[`fi${tckr}`];

      console.log("field action: ", fieldAction);

      switch (fieldAction) {
        case "deposit":
          uToken
            .approve(Principal.fromText(fiTokenAddr), value)
            .then(() => {
              fiToken.mintfi(value);
            })
            .catch((err) => console.log(err));
          break;
        case "withdraw":
          fiToken.redeem(value).catch((err) => console.log(err));
          break;
        case "borrow":
          fiToken.borrow(value).catch((err) => console.log(err));
          break;
        case "repay":
          fiToken.repay(value).catch((err) => console.log(err));
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
