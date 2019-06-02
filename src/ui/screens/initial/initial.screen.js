import React, { Component } from "react";
import { View, Text } from "react-native";
import { Thumbnail, List, ListItem } from "native-base";
import { ListComponent, BaseComponent } from "../../components";
import { Styles } from "./initial.style";

export class InitialScreen extends Component {
  renderLists(lists) {
    const { navigation } = this.props;
    return <ListComponent lista={lists} navigation={navigation} />;
  }

  render() {
    const { lists, navigation } = this.props;
    return (
      <BaseComponent containerStyle={Styles.container}>
        <View style={Styles.contentHeader}>
          <Thumbnail
            large
            source={require("../../../assets/images/perfil.jpg")}
          />
          <Text style={Styles.textName}>Seu Nome</Text>
        </View>
        <View style={Styles.content}>
          <List>
            <ListItem>
              <Text style={Styles.textList}>Minha Conta</Text>
            </ListItem>
            <ListItem>
              <Text style={Styles.textList}>Meus Cartões</Text>
            </ListItem>
            <ListItem>
              <Text style={Styles.textList}>Sair</Text>
            </ListItem>
          </List>
        </View>
        <View style={Styles.contentFooter} />
      </BaseComponent>
    );
  }
}
