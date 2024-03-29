import React, { createContext, useReducer } from "react";
import { Container } from "@chakra-ui/layout";
import { AppActionType, appReducer } from "../store/reducers/Reducers";
import { allTokenData, defaultUserAmounts, userData } from "../utils/initialData";
import { AppStateType } from "../utils/types";
import Navbar from "./Navbar";
import { HttpAgent } from "@dfinity/agent";

export const initAppState: AppStateType = {
  isUserConnected: false,
  selectedTicker: "WICP",
  userData,
  selectedToken: allTokenData[0], // default value
  userAmounts: defaultUserAmounts,
  web3: {
    agent: (() => {
      const ag = new HttpAgent({ host: "http://127.0.0.1:8000" });
      if (process.env.NODE_ENV !== "production") {
        ag.fetchRootKey().catch((err) => {
          console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
          console.error(err);
        });
      }

      return ag;
    })(),
  },
  canisters: {},
};

type LayoutProps = {
  children: React.ReactNode;
};

export const AppContext = createContext<AppStateType>(initAppState);
export const AppDispatchContext = createContext<React.Dispatch<AppActionType>>(() => {});

function Layout(props: LayoutProps) {
  const [appState, appDispatch] = useReducer(appReducer, initAppState);

  return (
    <>
      <AppContext.Provider value={appState}>
        <AppDispatchContext.Provider value={appDispatch}>
          <Navbar />

          <Container as="main" maxW="container.lg" p={5} d="flex" flexDir="column" alignItems="center">
            {props.children}
          </Container>
        </AppDispatchContext.Provider>
      </AppContext.Provider>

      <footer></footer>
    </>
  );
}

export default Layout;
