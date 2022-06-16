import React from "react";
import "../src/fitoken_assets/styles/globals.css";
import type { AppProps } from "next/app";
import { ChakraProvider, CSSReset, extendTheme } from "@chakra-ui/react";

function MyApp({ Component, pageProps }: AppProps) {
  const theme = extendTheme({
    config: {
      initialColorMode: "dark",
    },
  });
  return (
    <ChakraProvider theme={theme}>
      <CSSReset />
      <Component {...pageProps} />
    </ChakraProvider>
  );
}

export default MyApp;
