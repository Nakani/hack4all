import React, { PureComponent } from "react";
import { View, Text, Image, TouchableOpacity } from "react-native";
import { Styles } from "./styles/header.styles";

export class HeaderComponent extends PureComponent {
  render() {
    const { ...rest } = this.props;
    return rest.transparent ? (
      <View>
        <Image source={require("../../../assets/images/logo/logo.png")} />
      </View>
    ) : (
      <Header
        style={{
          backgroundColor: "#262626"
        }}
      >
        <Left>
          {rest.goback ? (
            <Button transparent onPress={() => rest.navigation.goBack()}>
              <Icon style={Styles.icon} name="angle-left" type="FontAwesome5" />
            </Button>
          ) : null}
        </Left>
        <Body>
          <Title style={Styles.labelHeader}>{rest.headerName}</Title>
        </Body>
        <Right>
          <Button transparent>
            <Icon
              style={[Styles.icon, { fontSize: 20 }]}
              name="search"
              type="FontAwesome5"
            />
          </Button>
        </Right>
      </Header>
    );
  }
}
