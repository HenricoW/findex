import React from "react";
import { PersonIcon, RocketIcon, StatsIcon } from "./components/Icons/Icons";

export const sidebarLinks = [
  {
    path: "/moneymarket",
    name: "Money Market",
    icon: <StatsIcon color="inherit" />,
    // component: Dashboard,
  },
  {
    path: "/trade",
    name: "Trade Station",
    icon: <RocketIcon color="inherit" />,
    // component: Dashboard,
  },
  {
    path: "/account",
    name: "My Account",
    icon: <PersonIcon color="inherit" />,
    // component: Dashboard,
  },
];
