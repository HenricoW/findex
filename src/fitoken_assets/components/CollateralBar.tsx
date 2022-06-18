import { Box, Text } from "@chakra-ui/layout";
import { Progress } from "@chakra-ui/progress";
import { useContext } from "react";
import { collateralContext } from "./InteractionPanel";

function CollateralBar() {
  const { totalDeposits, totalLoaned } = useContext(collateralContext);
  const collateral = totalDeposits < 0.01 ? 0 : (totalLoaned / totalDeposits) * 100;

  return (
    <>
      <Box d="flex" alignItems="center" justifyContent="space-between">
        <Text py="1" color="gray.500">
          Updated Collateral:
        </Text>
        <Text py="1" fontWeight="bold">
          {collateral.toFixed(1)} %
        </Text>
      </Box>
      <Progress colorScheme="green" size="lg" value={collateral} mt="1" />
    </>
  );
}

export default CollateralBar;
