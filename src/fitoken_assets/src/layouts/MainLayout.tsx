import React from "react";
import { Box, Flex, Grid, useDisclosure } from "@chakra-ui/react";
import StatsSmall from "../components/Cards/StatsSmall";
import { GlobeIcon } from "../components/Icons/Icons";
import MainNavbar from "../components/Navigation/MainNavbar";
import MobileMenu from "../components/Navigation/MobileMenu";
import Sidebar from "../components/Navigation/Sidebar";
import PriceChart from "../components/Charts/PriceChart";
import CardGen from "../components/Cards/CardGen";

export const sidebarWidth = "280px";
export const navHeight = "111px";

const MainLayout = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Sidebar />
      <Box w={{ xl: `calc(100vw - ${sidebarWidth})` }} ml={{ base: "0", lg: sidebarWidth }} p={`${navHeight} 1em 0`}>
        <MainNavbar brandText="The app" onOpen={onOpen} />
        <Flex justifyContent="right" wrap="wrap" columnGap=".5em" rowGap=".5em">
          <StatsSmall
            title={"Total Liquidity"}
            amount={"$37,000"}
            percentage={55}
            icon={<GlobeIcon h={"24px"} w={"24px"} color="white" />}
          />
          <StatsSmall
            title={"This Token's Liquidity"}
            amount={"$5,800"}
            percentage={5}
            icon={<GlobeIcon h={"24px"} w={"24px"} color="white" />}
          />
        </Flex>

        <PriceChart />
        <Grid
          templateColumns={{ sm: "1fr", lg: "1.3fr 1.7fr" }}
          templateRows={{ sm: "repeat(2, 1fr)", lg: "1fr" }}
          gap=".5em"
          mt=".5em"
          mb={{ lg: "26px" }}
        >
          <CardGen />
          <CardGen />
        </Grid>
      </Box>
      <MobileMenu isOpen={isOpen} onClose={onClose} />
    </>
  );
};

export default MainLayout;
