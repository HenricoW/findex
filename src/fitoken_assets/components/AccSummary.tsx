import { Box, Container, Text } from "@chakra-ui/layout";
import { CircularProgress, CircularProgressLabel } from "@chakra-ui/progress";
import style from "../styles/AccSummary.module.css";
import React, { useContext, useEffect } from "react";
import { AppContext, AppDispatchContext } from "./Layout";
import { TokenDispatchContext } from "../../../pages";
import { Button } from "@chakra-ui/react";
import WelcomeBlub from "./WelcomeBlub";
import { ZERO_ADDR } from "../utils/initialData";
import { getTknPrices, getUserDepositAmounts, getWalletBalances } from "../utils/helpers";

function AccSummary() {
  const { userData, userAmounts, isUserConnected, canisters } = useContext(AppContext);
  const appDispatch = useContext(AppDispatchContext);

  const tknDataDispatch = useContext(TokenDispatchContext);

  useEffect(() => {
    (async () => {
      if (canisters) {
        if (userData.address !== ZERO_ADDR) {
          const payload = await getWalletBalances(userData.address, canisters);
          appDispatch({ type: "setWalletAmts", payload, target: "user" });
        }

        console.log("app wallet: ", userData.appWallet);
        if (userData.appWallet !== ZERO_ADDR) {
          const payload = await getUserDepositAmounts(userData.appWallet, canisters);
          appDispatch({ type: "setAccAmts", payload, target: "user" });
        }
      }
    })();
  }, [canisters, userData.address, userData.appWallet]);

  useEffect(() => {
    (async () => {
      // get token prices
      const prices = await getTknPrices();
      tknDataDispatch({ type: "setPrices", payload: prices });
    })();
  }, []);

  const createAnAcc = async () => {};

  const { totalDeposits, totalLoaned } = userAmounts;
  const userCollateral = totalDeposits < 0.01 ? 0 : (totalLoaned / totalDeposits) * 100;

  return (
    <>
      {isUserConnected ? (
        <Container
          as="section"
          maxW="container.md"
          bg="gray.800"
          border="1px"
          borderColor="gray.600"
          borderRadius="md"
          mx="10"
          mb="5"
          p="4"
        >
          <Box d="flex" flexWrap="wrap" justifyContent="space-around">
            <Box className="accountValues" d="flex" alignItems="center">
              <img src={userData.blockie} width="70px" height="70px" className={style.blockieImg} alt="user blockie" />
              <Box d="flex" flexDir="column" pb="2" ml="4">
                <Text maxW="260px" color="gray.500" isTruncated>
                  Your Account:
                </Text>
                <Text maxW="260px" isTruncated mb="3">
                  {userData.appWallet}
                </Text>
                <Box d="flex" alignItems="center" justifyContent="space-between" flexGrow={1} mb="1">
                  <Text fontSize="sm" color="gray.500">
                    Total Deposits:
                  </Text>
                  <Text fontSize="sm" fontWeight="bold">
                    $ {totalDeposits.toFixed(2)}
                  </Text>
                </Box>
                <Box d="flex" alignItems="center" justifyContent="space-between" flexGrow={1}>
                  <Text fontSize="sm" color="gray.500">
                    Total Borrowed:
                  </Text>
                  <Text fontSize="sm" fontWeight="bold">
                    $ {totalLoaned.toFixed(2)}
                  </Text>
                </Box>
              </Box>
            </Box>
            {userData.appWallet === ZERO_ADDR ? (
              <Box d="flex" flexDir="column" justifyContent="center">
                <Button variant="outline" colorScheme="twitter" onClick={createAnAcc}>
                  CREATE AN ACCOUNT
                </Button>
              </Box>
            ) : (
              <Box className="collGraph" d="flex" flexDir="column" alignItems="center" ml="4">
                <CircularProgress size="95px" thickness="15px" value={userCollateral} color="green.400" mb="2">
                  <CircularProgressLabel>{userCollateral.toFixed(0)}%</CircularProgressLabel>
                </CircularProgress>
                <Text fontSize="sm" color="gray.500">
                  Collateral Rate
                </Text>
              </Box>
            )}
          </Box>
        </Container>
      ) : (
        <WelcomeBlub />
      )}
    </>
  );
}

export default AccSummary;
