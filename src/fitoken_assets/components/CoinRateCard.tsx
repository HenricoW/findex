import { Box, HStack, Text, VStack } from "@chakra-ui/layout";
import { Dispatch, SetStateAction, useContext } from "react";
import { tokenDataType } from "../utils/types";
import { AppContext, AppDispatchContext } from "./Layout";

export type CoinRateCardProps = {
  tokenDetail: tokenDataType;
  setIsInteractOpen: Dispatch<SetStateAction<boolean>>;
  onOpen: () => void;
};

function CoinRateCard({ tokenDetail, setIsInteractOpen, onOpen }: CoinRateCardProps) {
  const { ticker, imgUrl, saveRate, borrRate } = tokenDetail;

  const appDispatch = useContext(AppDispatchContext);
  const { isUserConnected } = useContext(AppContext);

  const clickHandler = () => {
    appDispatch({ type: "selectToken", payload: tokenDetail.ticker, target: "token" });
    setIsInteractOpen(true);
  };

  return (
    <Box
      bg="gray.700"
      d="flex"
      justifyContent="space-between"
      py={2}
      px={8}
      border="1px"
      borderColor="gray.600"
      _hover={{
        background: "gray.600",
        cursor: "pointer",
      }}
      onClick={() => (isUserConnected ? clickHandler() : onOpen())}
    >
      <HStack spacing="3">
        <img src={imgUrl} width="40px" height="40px" alt={ticker} />
        <Text fontWeight="bold" fontSize="lg">
          {ticker}
        </Text>
      </HStack>

      <Box d="flex" justifyContent="space-between" flexBasis="45%">
        <VStack spacing="1">
          <Text fontSize="xs" color="gray.400">
            Savings APY
          </Text>
          <Text fontSize="lg" fontWeight="bold">
            {saveRate.toFixed(2)} %
          </Text>
        </VStack>
        <VStack spacing="1">
          <Text fontSize="xs" color="gray.400">
            Borrow APY
          </Text>
          <Text fontSize="lg" fontWeight="bold">
            {borrRate.toFixed(2)} %
          </Text>
        </VStack>
      </Box>
    </Box>
  );
}

export default CoinRateCard;
