import React, { Component } from "react";
import { View, Text, Image, TouchableOpacity } from "react-native";
import { connect } from "react-redux";
import {
  ListComponent,
  BaseComponent,
  VideoComponent,
  HeaderComponent
} from "../../components";
import { Styles } from "./home.style";

export class HomeScreen extends Component {
  renderLists(lists) {
    const { navigation } = this.props;
    return <ListComponent lista={lists} navigation={navigation} />;
  }

  render() {
    return (
      <BaseComponent containerStyle={Styles.container}>
        <VideoComponent />
        <View style={Styles.containerHome}>
          <View style={Styles.content}>
            <HeaderComponent transparent={true} />
          </View>
          <View style={Styles.content}>
            <Text style={Styles.textSloganTitle}>
              Bem vindo ao Easy Comanda
            </Text>
          </View>
          <View style={Styles.contentSlogan}>
            <Text style={Styles.textSlogan}>Evite Filas</Text>
            <Text style={Styles.textSlogan}>Pague com Facilidade</Text>
            <Text style={Styles.textSlogan}>
              Ganhe mais Tempo para aproveitar
            </Text>
            <Text style={Styles.textSlogan}>Promoções Exclusivas</Text>
          </View>
          <View style={Styles.contentFooter} />
        </View>
      </BaseComponent>
    );
  }
}

const mapStateToProps = state => ({
  auth: state.auth
});

export const HomeScreenConnected = connect(
  mapStateToProps
  // mapDispatchToProps
)(HomeScreen);
