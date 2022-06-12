import React from "react";
import { Box, useStyleConfig } from "@chakra-ui/react";

const CardBody = ({ variant, children, ...rest }) => {
  const styles = useStyleConfig("CardBodyTheme", { variant });

  return (
    <Box __css={styles} {...rest}>
      {children}
    </Box>
  );
};

export default CardBody;
