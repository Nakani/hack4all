import React, { Component } from "react";
import { View, Text, Image, TouchableOpacity } from "react-native";
import { Button, H3 } from "native-base";
import { BaseComponent, HeaderComponent } from "../../components";
import { navigationService } from "../../../services/navigation.service";
import { Styles } from "./login.style";
import Video from "react-native-video";

export class LoginScreen extends Component {
  onPressGoToLogin() {
    navigationService.goTo(this, "Home");
  }
  render() {
    return (
      <BaseComponent containerStyle={Styles.container}>
        <Video
          source={require("../../../assets/videoLogin.mp4")}
          muted={true}
          repeat={true}
          resizeMode={"cover"}
          rate={1.0}
          ignoreSilentSwitch={"obey"}
          style={Styles.backgroundVideo}
        />
        <View style={Styles.content}>
          <HeaderComponent transparent={true} />
        </View>
        <View style={Styles.content}>
          <Text style={Styles.textSlogan}>
            Crie sua conta para continuar se você já possui, faça login
          </Text>
        </View>
        <View style={Styles.contentFooter}>
          <Button style={Styles.button}>
            <Text style={Styles.textButton}> Criar Conta </Text>
          </Button>
          <TouchableOpacity onPress={() => this.onPressGoToLogin()}>
            <Text style={Styles.textFooter}>
              Já possui conta?
              <H3 style={Styles.h3}> Clique aqui</H3>
            </Text>
          </TouchableOpacity>
        </View>
      </BaseComponent>
    );
  }
}
