import { Stack, Modal, ModalOverlay, ModalContent, ModalHeader } from "@chakra-ui/react";
import { ModalBody, ModalCloseButton, ModalFooter, Button } from "@chakra-ui/react";
import { useDisclosure } from "@chakra-ui/react";
import React, { useContext, useEffect, useState } from "react";
import { TokenContext, TokenDispatchContext } from "../../../pages";
import { getTokenRates } from "../utils/helpers";
import CoinRateCard from "./CoinRateCard";
import { AppContext } from "./Layout";

export type TokenBarsPropsType = {
  setIsInteractOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

function TokenBars({ setIsInteractOpen }: TokenBarsPropsType) {
  const tokenData = useContext(TokenContext);
  const tknDataDispatch = useContext(TokenDispatchContext);

  const { isUserConnected, contracts } = useContext(AppContext); // hack to get tokenData up to date :( -dispatch in [AccSummary.tsx] not triggering update in this comp's data
  const [_, setTknData] = useState(new Array(tokenData.length).fill(0)); // hack to trigger tokenData-based rerender to show APYs before wallet connect

  const { isOpen, onOpen, onClose } = useDisclosure();

  useEffect(() => {
    (async () => {
      console.log("token bars' tokenData: ", tokenData);
      const suppBorrRates = await getTokenRates(contracts ? contracts : {});
      tknDataDispatch({ type: "setSuppRates", payload: suppBorrRates.supply });
      tknDataDispatch({ type: "setBorrRates", payload: suppBorrRates.borrow });
      setTknData(suppBorrRates.supply);
    })();
  }, [isUserConnected]);

  return (
    <>
      <Stack as="section" spacing={2} minW="100%">
        {tokenData.map((tknInfo) => (
          <CoinRateCard
            key={tknInfo.ticker}
            tokenDetail={tknInfo}
            setIsInteractOpen={setIsInteractOpen}
            onOpen={onOpen}
          />
        ))}
      </Stack>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Not Connected</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <p>Please connect your wallet to interact with this contract.</p>
          </ModalBody>

          <ModalFooter>
            <Button colorScheme="blue" mr={3} onClick={onClose}>
              Close
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}

export default TokenBars;
