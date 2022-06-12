import { extendTheme } from "@chakra-ui/react";
import { mode } from "@chakra-ui/theme-tools";
const { CardTheme, CardHeadTheme, CardBodyTheme } = require("./cardTheme");

const globalStyles = {
  colors: {
    gray: {
      700: "#1f2733",
    },
    brand: {
      700: "#4F4FB0",
    },
  },
  styles: {
    global: (props) => ({
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

export const theme = extendTheme(globalStyles, CardTheme, CardHeadTheme, CardBodyTheme);
