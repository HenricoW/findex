import { useDisclosure } from "@chakra-ui/react";
import React from "react";
import MainNavbar from "../components/Navigation/MainNavbar";
import MobileMenu from "../components/Navigation/MobileMenu";
import Sidebar from "../components/Navigation/Sidebar";

export const sidebarWidth = "280px";

const MainLayout = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Sidebar />
      <MainNavbar brandText="The app" onOpen={onOpen} />
      <MobileMenu isOpen={isOpen} onClose={onClose} />
    </>
  );
};

export default MainLayout;
