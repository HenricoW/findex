import React, { useContext } from "react";
import { Box, HStack, Text, VStack } from "@chakra-ui/react";
import { AppContext } from "./Layout";

function TokenData() {
  const { selectedToken } = useContext(AppContext);
  return (
    <>
      <Box d="flex" justifyContent="space-between" py={2} px={4}>
        <HStack spacing="3">
          <img height="60px" width="60px" src={selectedToken.imgUrl} alt={selectedToken.ticker} />
          <Text fontWeight="bold" fontSize="lg">
            {selectedToken.ticker}
          </Text>
        </HStack>
        <Box d="flex" justifyContent="space-between" flexBasis="45%">
          <VStack spacing="1">
            <Text fontSize="xs" color="gray.400">
              Savings APY
            </Text>
            <Text fontSize="lg" fontWeight="bold" color="green.300">
              {selectedToken.saveRate.toFixed(2)} %
            </Text>
          </VStack>
          <VStack spacing="1">
            <Text fontSize="xs" color="gray.400">
              Borrow APY
            </Text>
            <Text fontSize="lg" fontWeight="bold" color="orange.300">
              {selectedToken.borrRate.toFixed(2)} %
            </Text>
          </VStack>
        </Box>
      </Box>
      <Box d="flex" justifyContent="space-between" pt="1" px="5">
        <Text fontSize="lg" textAlign="center">
          COLLATERAL LIMIT:
        </Text>
        <Text fontSize="lg" textAlign="center" fontWeight="bold">
          80 %
        </Text>
      </Box>
    </>
  );
}

export default TokenData;
