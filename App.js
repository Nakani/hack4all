import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { Provider } from "react-redux";
import Store from "./src/reduxs/store-config";
import AppContainer from "./src/router";

export default class App extends React.Component {
  render() {
    return (
      <View style={{ backgroundColor: "white", flex: 1 }}>
        <Provider store={Store}>
          <AppContainer />
        </Provider>
      </View>
    );
  }
}
