import React from "react";
import { Box, Button, Flex, Image, Stack, Text, useColorMode } from "@chakra-ui/react";
import { sidebarLinks } from "../../routes";
import SidebarLink from "./SidebarLink";
import Separator from "../Misc/Separator";
import { sidebarWidth } from "../../layouts/MainLayout";

const Sidebar = () => {
  const { colorMode, toggleColorMode } = useColorMode();
  return (
    <>
      <Box display={{ base: "none", lg: "block" }} w={sidebarWidth} px=".5em" position="fixed">
        <Box pt={"25px"} mb="12px">
          <Image src={"img/avatars/avatar1.png"} w="130px" h="130px" borderRadius="50%" m="20px auto" />
          <Text fontSize="md" textAlign="center" mb="20px">
            jaldsk-asjfi...flask-fakjf
          </Text>
          <Separator />

          <div style={{ margin: "30px 10px", padding: "0 .3em" }}>
            <Flex justifyContent="space-between" my="10px">
              <Text fontSize="md" fontWeight="bold">
                ICP
              </Text>
              <Text fontSize="md">23.95</Text>
            </Flex>
            <Flex justifyContent="space-between" my="10px">
              <Text fontSize="md" fontWeight="bold">
                Cycles
              </Text>
              <Text fontSize="md">23.95</Text>
            </Flex>
          </div>

          <Separator />
        </Box>
        <Stack direction="column" mb="40px">
          {sidebarLinks.map((linkData) => (
            <SidebarLink key={linkData.name} name={linkData.name} icon={linkData.icon} />
          ))}
        </Stack>
        <Separator />
        <Button display="block" m="3em auto 0" onClick={toggleColorMode}>
          Toggle {colorMode === "light" ? "Dark" : "Light"}
        </Button>
      </Box>
    </>
  );
};

export default Sidebar;
