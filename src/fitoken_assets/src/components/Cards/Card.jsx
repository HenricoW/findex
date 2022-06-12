import React from "react";
import { Box, useStyleConfig } from "@chakra-ui/react";

const Card = ({ variant, children, ...rest }) => {
  const styles = useStyleConfig("Card", { variant });

  return (
    <Box __css={styles} {...rest}>
      {children}
    </Box>
  );
};

export default Card;
