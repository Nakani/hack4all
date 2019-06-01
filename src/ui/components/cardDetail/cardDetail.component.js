import React, { PureComponent } from "react";
import {
  Text,
  View,
  TouchableOpacity,
  Linking,
  Platform,
  Alert
} from "react-native";
import { Card, CardItem, Body, Icon, Button } from "native-base";
import { Styles } from "./cardDetail.style";
export class CardDetailComponent extends PureComponent {
  callNumber(phone) {
    let phoneNumber = phone;
    if (Platform.OS !== "android") {
      phoneNumber = `telprompt:${phone}`;
    } else {
      phoneNumber = `tel:${phone}`;
    }
    Linking.canOpenURL(phoneNumber)
      .then(supported => {
        if (!supported) {
          Alert.alert("Aviso!", "Número Inválido");
        } else {
          return Linking.openURL(phoneNumber);
        }
      })
      .catch(err => console.log(err));
  }

  renderCardItemHeader(detail) {
    return (
      <CardItem header>
        <View style={Styles.containerCardHeader}>
          <View style={Styles.contentCardHeader} />
          <View style={Styles.contentCardHeader}>
            <Text style={Styles.labelCardHeader}>{detail}</Text>
          </View>
        </View>
      </CardItem>
    );
  }

  renderCardItemBody(textDescription) {
    return (
      <CardItem>
        <Body>
          <View style={Styles.contentDescription}>
            <Text style={Styles.textDescription}>{textDescription}</Text>
          </View>
        </Body>
      </CardItem>
    );
  }

  render() {
    const { ...rest } = this.props;

    return (
      <Card>
        {this.renderCardItemHeader(rest.detail)}
        {this.renderCardItemBody(rest.detail.texto)}
      </Card>
    );
  }
}
