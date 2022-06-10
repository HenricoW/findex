import React from "react";
import { Box, Button, Flex, Link, useColorModeValue } from "@chakra-ui/react";
import { sidebarWidth } from "../../layouts/MainLayout";

interface MainNavbarProps {
  brandText: string;
  onOpen: () => void;
}

export default function MainNavbar({ brandText, onOpen }: MainNavbarProps) {
  let mainText = useColorModeValue("gray.700", "gray.200");
  let navbarBackdrop = "blur(21px)";
  const navbarShadow = "none";
  const marginX = "30px";

  const navbarBg = useColorModeValue(
    "linear-gradient(112.83deg, rgba(255, 255, 255, 0.82) 0%, rgba(255, 255, 255, 0.8) 110.84%)",
    "linear-gradient(112.83deg, rgba(255, 255, 255, 0.21) 0%, rgba(255, 255, 255, 0) 110.84%)"
  );
  const navbarBorder = useColorModeValue("#FFFFFF", "rgba(255, 255, 255, 0.31)");
  const navbarFilter = useColorModeValue("none", "drop-shadow(0px 7px 23px rgba(0, 0, 0, 0.05))");
  let secondaryMargin = "0px";

  return (
    <Flex
      position={"fixed"}
      boxShadow={navbarShadow}
      bg={{ base: "none", md: navbarBg }}
      filter={navbarFilter}
      backdropFilter={navbarBackdrop}
      border={{ base: "none", md: `1px solid ${navbarBorder}` }}
      justifyContent="space-between"
      alignItems="center"
      borderRadius="16px"
      minH="75px"
      lineHeight="25.6px"
      mx="auto"
      mt={secondaryMargin}
      pb="8px"
      right={marginX}
      px={{ base: "0", md: "30px" }}
      pt="8px"
      top={{ base: "5px", md: "18px" }}
      w={{ base: `calc(100vw - 2 * ${marginX})`, xl: `calc(100vw - 2 * ${marginX} - ${sidebarWidth})` }}
    >
      <Box>
        <Link
          color={mainText}
          href="#"
          bg="inherit"
          borderRadius="inherit"
          fontWeight="bold"
          _hover={{ color: { mainText } }}
          _active={{
            bg: "inherit",
            transform: "none",
            borderColor: "transparent",
          }}
          _focus={{
            boxShadow: "none",
          }}
        >
          {brandText}
        </Link>
      </Box>
      <Flex gap="20px">
        <Button display={{ base: "block", md: "none" }} onClick={onOpen}>
          Menu
        </Button>
        <Button>Connect</Button>
      </Flex>
    </Flex>
  );
}
