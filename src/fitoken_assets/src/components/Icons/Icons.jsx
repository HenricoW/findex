import React from "react";
import { Icon } from "@chakra-ui/react";
import { FaChartBar, FaUserAstronaut, FaRocket, FaGlobeAfrica } from "react-icons/fa";
import { MdOutlineDashboard, MdArrowDropUp, MdArrowDropDown, MdMenu } from "react-icons/md";

export const StatsIcon = (props) => <Icon as={FaChartBar} {...props} />;

export const PersonIcon = (props) => <Icon as={FaUserAstronaut} {...props} />;

export const RocketIcon = (props) => <Icon as={FaRocket} {...props} />;

export const DashboardLogo = (props) => <Icon as={MdOutlineDashboard} {...props} />;

export const TriUpIcon = (props) => <Icon as={MdArrowDropUp} {...props} />;

export const TriDownIcon = (props) => <Icon as={MdArrowDropDown} {...props} />;

export const MenuIcon = (props) => <Icon as={MdMenu} {...props} />;
