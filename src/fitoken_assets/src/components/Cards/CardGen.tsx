import React from "react";
import { Button, Flex, Spacer, Text, useColorModeValue } from "@chakra-ui/react";
import Card from "./Card";
import CardBody from "./CardBody";

const CardGen = () => {
  const title = "Subtitle above title";
  const name = "Basic Card";
  const description = "Card body text to say whatever you want.";
  const textColor = useColorModeValue("gray.700", "white");

  return (
    <Card variant="panel" p="1.2rem">
      <CardBody variant="" w="100%">
        <Flex flexDirection="column" h="100%" lineHeight="1.6">
          <Text fontSize="sm" color="gray.400" fontWeight="bold">
            {title}
          </Text>
          <Text fontSize="lg" color={textColor} fontWeight="bold" pb=".5rem">
            {name}
          </Text>
          <Text fontSize="sm" color="gray.400" fontWeight="normal">
            {description}
          </Text>
          <Spacer />
        </Flex>
        <Spacer />
      </CardBody>
    </Card>
  );
};

export default CardGen;
