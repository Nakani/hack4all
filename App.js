import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { Provider } from "react-redux";
import Store from "./src/reduxs/store-config";
import AppContainer from "./src/router";
import {
  CartInitializer,
  CategoryInitializer,
  CheckInitializer,
  DiscountsClubInitializer,
  OfferInitializer,
  OrderHistoryInitializer,
  OrderTypeSelectionInitializer,
  UnityDetailInitializer,
  UnityListInitializer,
  GastronomyProps
} from "gastronomy-module";

let props = new GastronomyProps();
props.appName = "Gastronomy";
props.moduleColorPrimary = "COLOR";
props.moduleColorSecondary = "COLOR";
props.moduleColorGradient = "COLOR";

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
