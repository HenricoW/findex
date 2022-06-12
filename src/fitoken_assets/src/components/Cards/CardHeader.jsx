import React from "react";
import { Box, useStyleConfig } from "@chakra-ui/react";

const CardHeader = ({ variant, children, ...rest }) => {
  const styles = useStyleConfig("CardHeadTheme", { variant });

  return (
    <Box __css={styles} {...rest}>
      {children}
    </Box>
  );
};

export default CardHeader;
