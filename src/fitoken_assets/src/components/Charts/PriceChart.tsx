import React from "react";
import ReactApexChart from "react-apexcharts";
import { Box, Flex, Text, useColorModeValue } from "@chakra-ui/react";
import { lineChartData, lineChartOptions } from "../../temp_data/chartData";
import Card from "../Cards/Card";
import CardHeader from "../Cards/CardHeader";
import { TriDownIcon, TriUpIcon } from "../Icons/Icons";

const PriceChart = () => {
  const title = "XTC Price";
  const percentage = 14.37;
  const textColor = useColorModeValue("gray.700", "gray.400");

  return (
    <Card variant="panel" mb={{ sm: "1em", lg: "0px" }} mt=".5em">
      <CardHeader variant="" mb="0px" pl="22px">
        <Flex direction="column" alignSelf="flex-start">
          <Text fontSize="lg" color={textColor} fontWeight="bold">
            {title}
          </Text>
          <Flex alignItems="center">
            <Text fontSize="1.2em" color="gray.100" fontWeight="bold" mr="5px">
              $ 17.44
            </Text>
            {percentage > 0 ? (
              <TriUpIcon fontSize="1.5em" color="green.400" />
            ) : (
              <TriDownIcon fontSize="1.5em" color="red.400" />
            )}
            <Text color={percentage > 0 ? "green.400" : "red.400"} fontSize="md">
              {`${percentage}%`}
            </Text>
          </Flex>
        </Flex>
      </CardHeader>
      <Box w="100%" h={{ sm: "300px" }} ps="8px">
        <ReactApexChart options={lineChartOptions} series={lineChartData} type="area" width="100%" height="100%" />
      </Box>
    </Card>
  );
};

export default PriceChart;
