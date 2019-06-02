import { StyleSheet, Dimensions } from "react-native";
const { height } = Dimensions.get("window");

export const Styles = StyleSheet.create({
  backgroundVideo: {
    height: height,
    position: "absolute",
    top: 0,
    left: 0,
    alignItems: "stretch",
    bottom: 0,
    right: 0,
    top: 0,
    left: 0,
    flex: 1
  }
});
