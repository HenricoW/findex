import React from "react";
import { ChakraProvider, extendTheme } from "@chakra-ui/react";
import MainLayout from "./layouts/MainLayout";

const colors = {
  brand: {
    700: "#4F4FB0",
  },
};

const theme = extendTheme({ colors });

const App = () => {
  return (
    <ChakraProvider theme={theme}>
      <MainLayout />
    </ChakraProvider>
  );
};

export default App;
