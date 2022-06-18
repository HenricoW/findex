import { createContext, Dispatch, SetStateAction, useContext, useReducer } from "react";
import { Tab, TabList, TabPanel, TabPanels, Tabs } from "@chakra-ui/tabs";
import { Button } from "@chakra-ui/button";
import { Container } from "@chakra-ui/layout";
import PanelInputGroup from "./PanelInputGroup";
import { collateralReducer } from "../store/reducers/Reducers";
import CollateralBar from "./CollateralBar";
import { AppContext } from "./Layout";
import TokenData from "./TokenData";
import { defaultUserAmounts } from "../utils/initialData";

export type InteractionPanelProps = {
  setIsInteractOpen: Dispatch<SetStateAction<boolean>>;
  isInteractOpen: boolean;
};

export const collateralContext = createContext(defaultUserAmounts); // for separate coll calcs

function InteractionPanel({ setIsInteractOpen }: InteractionPanelProps) {
  const { userAmounts, isUserConnected } = useContext(AppContext);
  const [usrFieldState, fieldsDispatch] = useReducer(collateralReducer, userAmounts);

  return (
    <collateralContext.Provider value={usrFieldState}>
      {isUserConnected ? (
        <Container maxW="container.md" border="1px" borderColor="gray.600" borderRadius="md" p="4" mb="5">
          <TokenData />

          <Tabs align="center" colorScheme="twitter">
            <TabList>
              <Tab>Save</Tab>
              <Tab>Borrow</Tab>
            </TabList>
            <TabPanels>
              <TabPanel>
                <PanelInputGroup panelType={"savePanel"} fieldsDispatch={fieldsDispatch} />
              </TabPanel>
              <TabPanel>
                <PanelInputGroup panelType={"borrowPanel"} fieldsDispatch={fieldsDispatch} />
              </TabPanel>
            </TabPanels>
          </Tabs>

          <Container d="flex" flexDir="column" maxW="container.md" pt="2">
            <CollateralBar />
            <Button
              variant="outline"
              colorScheme="red"
              d="block"
              mt="8"
              mx="auto"
              w="40"
              onClick={() => setIsInteractOpen(false)}
            >
              CLOSE
            </Button>
          </Container>
        </Container>
      ) : null}
    </collateralContext.Provider>
  );
}

export default InteractionPanel;
