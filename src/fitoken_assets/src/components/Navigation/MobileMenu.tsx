import { Drawer, DrawerBody, DrawerContent, DrawerOverlay } from "@chakra-ui/react";
import React from "react";
import { sidebarLinks } from "../../routes";
import SidebarLink from "./SidebarLink";

interface MobileMenuProps {
  isOpen: boolean;
  onClose: () => void;
}

const MobileMenu = ({ isOpen, onClose }: MobileMenuProps) => {
  return (
    <>
      <Drawer placement="bottom" onClose={onClose} isOpen={isOpen}>
        <DrawerOverlay />
        <DrawerContent>
          <DrawerBody>
            {sidebarLinks.map((linkData) => (
              <SidebarLink key={linkData.name} name={linkData.name} icon={linkData.icon} />
            ))}
          </DrawerBody>
        </DrawerContent>
      </Drawer>
    </>
  );
};

export default MobileMenu;
