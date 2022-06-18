import { NumberInput, NumberInputField } from "@chakra-ui/number-input";

type NumInputArgType = {
  value: string;
  onChange: (valueAsString: string, valueAsNumber: number) => void;
  precision: number;
  outOfRange: boolean;
};

function NumInput({ value, onChange, precision, outOfRange }: NumInputArgType) {
  return (
    <NumberInput
      value={value}
      onChange={onChange}
      precision={precision}
      keepWithinRange={false}
      clampValueOnBlur={false}
      isInvalid={outOfRange}
      focusBorderColor={outOfRange ? "red.600" : "blue.500"}
    >
      <NumberInputField />
    </NumberInput>
  );
}

export default NumInput;
