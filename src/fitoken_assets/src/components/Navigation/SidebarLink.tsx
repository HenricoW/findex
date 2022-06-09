import { Button, Flex, Text } from "@chakra-ui/react";
import React from "react";

interface SidebarLinkProps {
  name: string;
  icon: React.ReactNode;
}

const SidebarLink = ({ name, icon }: SidebarLinkProps) => {
  return (
    <Button
      boxSize="initial"
      justifyContent="flex-start"
      alignItems="center"
      bg="transparent"
      mx={{ xl: "auto" }}
      py="1em"
      borderRadius="15px"
      _hover={{ backgroundColor: "#3f3f3f" }}
      w="100%"
      _active={{
        bg: "inherit",
        transform: "none",
        borderColor: "transparent",
      }}
      _focus={{
        boxShadow: "none",
      }}
    >
      <Flex>
        <Flex
          alignItems={"center"}
          justifyContent={"center"}
          borderRadius={"12px"}
          bg="brand.700"
          color="white"
          h="30px"
          w="30px"
          me="12px"
        >
          {icon}
        </Flex>
        <Text my="auto" fontSize="sm">
          {name}
        </Text>
      </Flex>
    </Button>
  );
};

export default SidebarLink;
