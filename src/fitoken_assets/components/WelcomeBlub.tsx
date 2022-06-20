import { Box, Container, Heading, Text } from "@chakra-ui/react";
import React from "react";

function WelcomeBlub() {
  return (
    <Container maxW={"container.md"}>
      <Box mb={6} py={12} textAlign="center">
        <Heading mb={6}>Welcome to Finivest</Heading>
        <Text fontSize="xl" mb="1.5em">
          Psst... Hey, want access to a token but don't want to sell your current bags 💰💰? No worries fren, use
          Finitrade to save your tokens, then borrow your token against those savings! 😎
        </Text>
        <Text fontSize="xl">Connect then click one of the items below to get started.</Text>
      </Box>
    </Container>
  );
}

export default WelcomeBlub;
