import React from "react";
import { ChakraProvider, extendTheme } from "@chakra-ui/react";
import MainLayout from "./layouts/MainLayout";
import { mode } from "@chakra-ui/theme-tools";

export const globalStyles = {
  colors: {
    gray: {
      700: "#1f2733",
    },
    brand: {
      700: "#4F4FB0",
    },
  },
  styles: {
    global: (props: any) => ({
      body: {
        bg: mode("gray.50", "gray.800")(props),
        fontFamily: "Helvetica, sans-serif",
      },
      html: {
        fontFamily: "Helvetica, sans-serif",
      },
    }),
  },
};

const theme = extendTheme(globalStyles);

const App = () => {
  return (
    <ChakraProvider theme={theme}>
      <MainLayout />
    </ChakraProvider>
  );
};

export default App;
