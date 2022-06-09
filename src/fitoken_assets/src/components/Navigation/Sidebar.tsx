import React from "react";
import { Box, Flex, Image, Stack, Text } from "@chakra-ui/react";
import { sidebarLinks } from "../../routes";
import SidebarLink from "./SidebarLink";
import Separator from "../Misc/Separator";

const Sidebar = () => {
  return (
    <>
      <Box display={{ sm: "none", xl: "block" }} w="250px" px=".5em" position="fixed">
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
      </Box>
    </>
  );
};

export default Sidebar;
