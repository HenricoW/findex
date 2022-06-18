import { Dispatch, useContext, useEffect, useState } from "react";
import { FormControl, FormLabel } from "@chakra-ui/form-control";
import { Box, HStack, Text } from "@chakra-ui/layout";
import { Button } from "@chakra-ui/button";
import NumInput from "./NumInput";
import { AppContext } from "./Layout";
import { PanelInputCtxt } from "./ContractActions";
import { getInputConfig, inputDispatchConfig } from "../utils/helpers";

type PanelInputGroupProps = {
  panelType: string;
  fieldsDispatch: Dispatch<{
    type: string;
    payload: number;
    origTotals: {
      totalDeposits: number;
      totalLoaned: number;
    };
  }>;
};

const btnText = "submit";

function PanelInputGroup({ panelType, fieldsDispatch }: PanelInputGroupProps) {
  const [fieldAmt, setFieldAmt] = useState<{ [pos: string]: string }>({ top: "0", bottom: "0" });
  const [topOutOfRange, setTopOutOfRange] = useState(false);
  const [bottomOutOfRange, setBottomOutOfRange] = useState(false);

  const onFormSubmit = useContext(PanelInputCtxt);
  const { selectedToken, userAmounts } = useContext(AppContext);
  const { price, displayDecimals } = selectedToken;

  useEffect(() => {
    setFieldAmt({ top: "0", bottom: "0" });
  }, []);

  const fieldConfig = getInputConfig({ panelType, userAmounts, decimals: displayDecimals, price });

  // input change handler
  const handleChange = (val: string, pos: "top" | "bottom") => {
    if (val === "") return;
    const selektah: {
      [pos: string]: (arg: boolean) => void;
    } = {
      top: (arg) => setTopOutOfRange(arg),
      bottom: (arg) => setBottomOutOfRange(arg),
    };

    // two way binding
    setFieldAmt({ ...fieldAmt, [pos]: val });

    // validation feedback
    const limitAmount = fieldConfig[pos].helperAmount;
    const theVal = parseFloat(val);
    theVal > parseFloat(limitAmount) || theVal < 0 ? selektah[pos](true) : selektah[pos](false);

    if (panelType !== "fundingPanel") {
      const action = {
        type: inputDispatchConfig[panelType][pos],
        payload: theVal * price,
        origTotals: { totalDeposits: userAmounts.totalDeposits, totalLoaned: userAmounts.totalLoaned },
      };
      fieldsDispatch(action);
    }
  };

  // input field labels
  const inputWithLabel = (pos: "top" | "bottom") => {
    return (
      <>
        <Box d="flex" alignItems="center" justifyContent="space-between">
          <FormLabel>{fieldConfig[pos].title}</FormLabel>
          <Text fontSize="sm" color="gray.500">
            {fieldConfig[pos].helperText}: {fieldConfig[pos].helperAmount + " " + selectedToken.ticker}
          </Text>
        </Box>
        <NumInput
          value={fieldAmt[pos]}
          onChange={(val) => handleChange(val, pos)}
          precision={displayDecimals}
          outOfRange={(pos as string) === " top" ? topOutOfRange : bottomOutOfRange}
        />
      </>
    );
  };

  return (
    <>
      <HStack alignItems="end">
        <FormControl id={panelType + "-top"} mt="0">
          {inputWithLabel("top")}
        </FormControl>
        <Button
          colorScheme={fieldConfig.btnColor}
          variant="outline"
          onClick={() => onFormSubmit(fieldConfig.top.ethRequest, +fieldAmt.top)}
        >
          {btnText.toUpperCase()}
        </Button>
      </HStack>
      <HStack alignItems="end">
        <FormControl id={panelType + "-bottom"} mt="6">
          {inputWithLabel("bottom")}
        </FormControl>
        <Button
          colorScheme={fieldConfig.btnColor}
          variant="outline"
          onClick={() => onFormSubmit(fieldConfig.bottom.ethRequest, +fieldAmt.bottom)}
        >
          {btnText.toUpperCase()}
        </Button>
      </HStack>
    </>
  );
}

export default PanelInputGroup;
