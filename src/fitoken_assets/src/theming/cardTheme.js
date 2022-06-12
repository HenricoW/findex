const Card = {
  baseStyle: {
    p: "22px",
    display: "flex",
    flexDirection: "column",
    wordWrap: "break-word",
    backgroundClip: "border-box",
  },
  variants: {
    panel: (props) => ({
      bg: props.colorMode === "dark" ? "gray.700" : "white",
      boxShadow: "0px 3.5px 5.5px rgba(0, 0, 0, 0.02)",
      borderRadius: "15px",
    }),
  },
  defaultProps: {
    variant: "panel",
  },
};

const BodyAndHead = {
  baseStyle: {
    display: "flex",
    width: "100%",
  },
};

export const CardTheme = {
  components: {
    Card,
  },
};

export const CardHeadTheme = {
  components: {
    BodyAndHead,
  },
};

export const CardBodyTheme = {
  components: {
    BodyAndHead,
  },
};
