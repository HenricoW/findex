import { Box, Container, Heading, Text } from "@chakra-ui/react";
import React from "react";

function WelcomeBlub() {
  return (
    <Container maxW={"container.md"}>
      <Box mb={6} py={12} textAlign="center">
        <Heading mb={6}>Welcome to Block Savings</Heading>
        <Text fontSize="xl">
          Make your dormant crypto work for you by generating passive income. Click one of the items below to get
          started.
        </Text>
      </Box>
    </Container>
  );
}

export default WelcomeBlub;
