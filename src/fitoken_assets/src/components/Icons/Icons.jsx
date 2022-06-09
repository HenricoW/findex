import React from "react";
import { Icon } from "@chakra-ui/react";
import { FaChartBar, FaUserAstronaut, FaRocket } from "react-icons/fa";
import { MdOutlineDashboard } from "react-icons/md";

export const StatsIcon = (props) => <Icon as={FaChartBar} {...props} />;

export const PersonIcon = (props) => <Icon as={FaUserAstronaut} {...props} />;

export const RocketIcon = (props) => <Icon as={FaRocket} {...props} />;

export const DashboardLogo = (props) => <Icon as={MdOutlineDashboard} {...props} />;
