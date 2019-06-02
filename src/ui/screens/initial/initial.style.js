import { StyleSheet, Dimensions } from "react-native";
const { height } = Dimensions.get("window");

export const Styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "space-between",
    alignItems: "center"
  },
  contentHeader: {
    width: "100%",
    height: 100,
    padding: 40,
    flex: 1,
    justifyContent: "space-between",
    alignItems: "center",
    borderBottomWidth: 1,
    borderColor: "#fff"
  },
  textName: {
    fontSize: 30,
    color: "#fff"
  },
  content: {
    width: "100%",
    height: "100%",
    paddingTop: 40,
    paddingLeft: 2,
    paddingRight: 5,
    flex: 1,
    alignItems: "flex-start"
  },
  textList: {
    color: "#fff",
    width: "100%"
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
