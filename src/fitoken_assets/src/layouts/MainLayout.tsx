import { useDisclosure } from "@chakra-ui/react";
import React from "react";
import MainNavbar from "../components/Navigation/MainNavbar";
import MobileMenu from "../components/Navigation/MobileMenu";
import Sidebar from "../components/Navigation/Sidebar";
import PriceChart from "../components/Charts/PriceChart";

export const sidebarWidth = "280px";

const MainLayout = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Sidebar />
      <Box w={{ xl: `calc(100vw - ${sidebarWidth})` }} ml={{ base: "0", lg: sidebarWidth }} p={`${navHeight} 1em 0`}>
      <MainNavbar brandText="The app" onOpen={onOpen} />
        <PriceChart />
      </Box>
      <MobileMenu isOpen={isOpen} onClose={onClose} />
    </>
  );
};

export default MainLayout;
