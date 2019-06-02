import { StyleSheet, Dimensions } from "react-native";
const { height } = Dimensions.get("window");

export const Styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "space-between",
    alignItems: "center"
  },
  containerHome: {
    backgroundColor: "rgba(51, 51, 51, 0.4)",
    height: "100%",
    position: "absolute",
    top: 0,
    left: 0,
    alignItems: "stretch",
    bottom: 0,
    right: 0,
    top: 0,
    left: 0,
    flex: 1,
    zIndex: 100
  },
  content: {
    width: "100%",
    height: "100%",
    padding: 40,
    flex: 1,
    alignItems: "center"
  },
  backgroundVideo: {
    height: height,
    position: "absolute",
    top: 0,
    left: 0,
    alignItems: "stretch",
    bottom: 0,
    right: 0,
    top: 0,
    left: 0
  },
  logo: {
    width: 50,
    height: 50
  },
  contentSlogan: {
    flex: 1,
    width: "100%",
    height: "100%",
    padding: 40,
    flex: 1,
    alignItems: "flex-start"
  },
  textSloganTitle: {
    fontSize: 30,
    fontWeight: "bold",
    color: "#fff",
    width: 250,
    textAlign: "center"
  },
  textSlogan: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#fff",
    width: 250,
    marginTop: 10
  },
  contentFooter: {
    flexDirection: "column",
    width: "100%",
    padding: 40,
    width: "100%",
    height: "100%",
    padding: 40,
    flex: 1,
    justifyContent: "space-between",
    alignItems: "center"
  },
  button: {
    backgroundColor: "rgba(255, 255, 255, 0.8)",
    width: "100%",
    height: 70,
    alignItems: "center"
  },
  textButton: {
    textAlign: "center",
    width: "100%",
    fontSize: 20,
    flex: 1
  },
  textFooter: {
    bottom: 0,
    width: "100%",
    fontSize: 18,
    textAlign: "center",
    color: "#959595",
    fontWeight: "bold"
  },
  h3: {
    color: "#fff",
    fontSize: 18
  }
});
