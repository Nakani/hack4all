import { StyleSheet } from "react-native";
export const Styles = StyleSheet.create({
  containerCardHeader: {
    flex: 1,
    justifyContent: "space-around",
    alignItems: "center",
    flexDirection: "row"
  },
  contentCardHeader: {
    flex: 1,
    justifyContent: "flex-start",
    alignItems: "center"
  },
  labelCardHeader: {
    fontSize: 9,
    textAlign: "center",
    color: "#E08C00"
  },
  contentDescription: {
    flex: 1,
    alignItems: "center",
    width: "100%",
    borderTopWidth: 1,
    padding: 10,
    borderTopColor: "#c3c3c3"
  },
  textDescription: {
    color: "#E08C00"
  }
});
