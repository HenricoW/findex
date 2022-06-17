import { useContext, useEffect, useState } from "react";
import { Button } from "@chakra-ui/button";
import { Box, Heading, HStack, Text } from "@chakra-ui/layout";
import styles from "../styles/Navbar.module.css";
import { shortAddress } from "../utils/helpers";
import { AppContext, AppDispatchContext } from "./Layout";
import { idlFactory as dip20Idl } from "../../declarations/mwicp";
import { idlFactory as fitokenIdl } from "../../declarations/fiwicp";
import { Principal } from "@dfinity/principal";
import { Actor, HttpAgent } from "@dfinity/agent";
import { Secp256k1KeyIdentity } from "@dfinity/identity";

// temp
const anonUserAddr = "2vxsx-fae";
const fiWicpId = "l7jw7-difaq-aaaaa-aaaaa-c";
const mwicp = "ai7t5-aibaq-aaaaa-aaaaa-c";
// const host = "https://mainnet.dfinity.network";
const host = "http://127.0.0.1:8000";
const alicePrinc = Principal.fromText("oj5h2-fpzeg-dzqv5-7h5y4-huhtb-pp34d-36hyt-lowk6-cy3xz-lfnq2-7ae");
// end temp

function Navbar() {
  const { isUserConnected, userData } = useContext(AppContext);
  const appDispatch = useContext(AppDispatchContext);

  const [netwName, setNetwName] = useState<"Local" | "IC Mainnet">("Local");
  const [userPrinc, setUserPrinc] = useState<Principal>(Principal.fromText("2vxsx-fae"));
  const [userIdentity, setUserIdentity] = useState<Secp256k1KeyIdentity | undefined>(undefined);

  const plugSignIn = () => {
    onConnect();
  };

  // temp
  const getIdentity = () => {
    const rawBuffer = new Uint8Array([
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    ]);
    const test_id = Secp256k1KeyIdentity.generate(rawBuffer);
    console.log("Created identity:", test_id.getPrincipal().toString());
    setUserIdentity(test_id);
    setUserPrinc(test_id.getPrincipal());
  };
  // end temp

  const getBalance = async () => {
    const agent = new HttpAgent({ host, identity: userIdentity });

    // Fetch root key for certificate validation during development
    if (process.env.NODE_ENV !== "production") {
      agent.fetchRootKey().catch((err) => {
        console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
        console.error(err);
      });
    }

    const mwicpActor = Actor.createActor(dip20Idl, {
      agent,
      canisterId: mwicp,
    });

    const fiwicpActor = Actor.createActor(fitokenIdl, {
      agent,
      canisterId: fiWicpId,
    });

    const abal = await mwicpActor.balanceOf(alicePrinc);
    console.log("Alice's mWICP balance: ", abal);
    const ubal = await mwicpActor.balanceOf(userPrinc);
    console.log("User's mWICP balance: ", ubal);
  };

  const onConnect = () => {
    const theUserData = { ...userData, address: anonUserAddr };
    appDispatch({ type: "signIn", payload: { ...theUserData, appWallet: anonUserAddr }, target: "user" });

    // TODO: commit to local storage
    // window.localStorage.setItem(
    //   "userData",
    //   JSON.stringify({ isUserConnected: true, userAddr: sessData.principalId })
    // );
  };

  useEffect(() => {
    (async () => {
      if (window.ic) {
        const connected = await window.ic.plug.isConnected();
        if (connected) {
          onConnect();
        }

        // TODO: rerender pg on Acc change
      }
    })();
  }, []);

  // TODO: reload on network change (local <-> ic)

  return (
    <Box as="header" py={5} px={6} bg="gray.700">
      <Box as="nav" d="flex" alignItems="center" justifyContent="space-between">
        <HStack spacing="4">
          <img height="40px" width="40px" src="/aave.7a37d675.svg" alt="Web3 Saver" />
          <Heading size="md">Web3 Saver</Heading>
        </HStack>
        <HStack spacing={isUserConnected ? "4" : "2"}>
          {isUserConnected ? (
            <>
              <Text
                border="1px"
                borderColor="gray.400"
                p="2"
                borderRadius="md"
                background={(netwName.length > 12 ? "orange" : "green") + ".700"}
              >
                {netwName}
              </Text>
              <Button variant="outline" colorScheme="blue" onClick={getBalance}>
                Get Balance
              </Button>
              <HStack spacing="3">
                <img
                  height="40px"
                  width="40px"
                  className={styles.accountImg}
                  src={userData.blockie}
                  alt="user blockie"
                />
                <Text>{shortAddress(userData.address)}</Text>
              </HStack>
            </>
          ) : (
            <>
              <Button variant="outline" colorScheme="blue" onClick={getIdentity}>
                Get ID
              </Button>
              <Button variant="outline" colorScheme="twitter" onClick={plugSignIn}>
                CONNECT
              </Button>
            </>
          )}
        </HStack>
      </Box>
    </Box>
  );
}

export default Navbar;
