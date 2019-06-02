import { StyleSheet } from "react-native";
export const styleView = StyleSheet.create({
  contentScan: {
    flexDirection: "row",
    flex: 1.5,
    backgroundColor: "transparent"
  },
  top: {
    flex: 0.5,
    backgroundColor: "black",
    opacity: 0.8,
    alignItems: "center",
    flexDirection: "column",
    justifyContent: "center",
    paddingBottom: "5%"
  },
  contentFooter: {
    flexDirection: "row",
    flex: 0.7,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "black",
    opacity: 0.8
  },
  detailFooter: {
    flex: 0.78,
    height: "100%",
    alignItems: "center",
    justifyContent: "center"
  }
});

export const styleText = StyleSheet.create({
  info: {
    color: "#c3c3c3",
    textAlign: "center",
    fontSize: 14,
    alignSelf: "center"
  }
});

export const styleImage = StyleSheet.create({
  logo: {
    resizeMode: "contain",
    width: "65%",
    height: "55%",
    marginBottom: 20,
    tintColor: "#fff"
  }
});

export const styleTouchable = StyleSheet.create({
  buttonClose: {
    alignSelf: "flex-start",
    marginTop: "15%",
    marginLeft: "5%"
  },
  btLanternaContainer: {
    borderWidth: 1,
    borderColor: "#c3c3c3",
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
    width: 51,
    height: 51,
    marginTop: "5%"
  }
});

export const styleCamera = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: "column"
  }
});
