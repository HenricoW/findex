import React from "react";
import { Flex, Stat, StatHelpText, StatLabel, StatNumber, useColorModeValue } from "@chakra-ui/react";
import Card from "./Card";
import CardBody from "./CardBody";

interface StatsSmallProps {
  title: string;
  amount: string;
  percentage: number;
  icon: React.ReactNode;
}

const StatsSmall = ({ title, amount, percentage, icon }: StatsSmallProps) => {
  const textColor = useColorModeValue("gray.700", "white");

  return (
    <Card variant="panel" minH="2.5em" minW={{ base: "100%", sm: "11em" }}>
      {/* <Card variant="panel" minH="2.5em" minW="11em"> */}
      <CardBody variant="">
        <Flex flexDirection="row" align="center" justify="center" w="100%">
          <Stat me="auto">
            <StatLabel fontSize="sm" color="gray.400" fontWeight="bold" pb=".1rem">
              {title}
            </StatLabel>
            <Flex>
              <StatNumber fontSize="lg" color={textColor}>
                {amount}
              </StatNumber>
              <StatHelpText
                alignSelf="flex-end"
                justifySelf="flex-end"
                m="0px"
                color={percentage > 0 ? "green.400" : "red.400"}
                fontWeight="bold"
                ps="3px"
                fontSize="md"
              >
                {percentage > 0 ? `+${percentage}%` : `${percentage}%`}
              </StatHelpText>
            </Flex>
          </Stat>
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
        </Flex>
      </CardBody>
    </Card>
  );
};

export default StatsSmall;
