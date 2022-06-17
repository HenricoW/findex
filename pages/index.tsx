import React, { createContext, useReducer, useState } from "react";
import type { NextPage } from "next";
import Head from "next/head";
import AccSummary from "../src/fitoken_assets/components/AccSummary";
import InteractionPanel from "../src/fitoken_assets/components/InteractionPanel";
import Layout from "../src/fitoken_assets/components/Layout";
import { tokenDataReducer } from "../src/fitoken_assets/store/reducers/Reducers";
import TokenBars from "../src/fitoken_assets/components/TokenBars";
import ContractActions from "../src/fitoken_assets/components/ContractActions";
import { allTokenData } from "../src/fitoken_assets/utils/initialData";
import { tokenDataType } from "../src/fitoken_assets/utils/types";
// temp
const canisterId = "";
export const devEnv: "local" | "ic" = "local";
// end temp

// app state independent of user action
export const TokenContext = createContext<tokenDataType[]>([]);
export const TokenDispatchContext = createContext<React.Dispatch<{ type: string; payload: number[] }>>(() => {});

const Home: NextPage = () => {
  const [isInteractOpen, setIsInteractOpen] = useState(false);
  const [tokenData, tokenDataDispatch] = useReducer(tokenDataReducer, allTokenData);

  return (
    <>
      <Head>
        <title>Crypto Saver</title>
        <meta name="description" content="Earn interest on your crypto assets" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Layout>
        <TokenContext.Provider value={tokenData}>
          <TokenDispatchContext.Provider value={tokenDataDispatch}>
            <AccSummary />
            {isInteractOpen ? (
              <ContractActions>
                <InteractionPanel setIsInteractOpen={setIsInteractOpen} isInteractOpen={isInteractOpen} />
              </ContractActions>
            ) : null}
            <TokenBars setIsInteractOpen={setIsInteractOpen} />
          </TokenDispatchContext.Provider>
        </TokenContext.Provider>
      </Layout>
    </>
  );
};

export default Home;
