import React, { Component } from "react";
import { Image, TouchableOpacity } from "react-native";
import {
  Card,
  CardItem,
  Thumbnail,
  Text,
  Button,
  Icon,
  Left,
  Body,
  Right
} from "native-base";
import { Styles } from "./list.section.style";

export class ListItemSection extends Component {
  render() {
    const { item, navigation } = this.props;

    return (
      <TouchableOpacity onPress={() => navigation.navigate("detail", { item })}>
        <Card>
          <CardItem>
            <Left>
              <Body>
                <Text style={Styles.title} />
              </Body>
            </Left>
          </CardItem>
          <CardItem cardBody>
            <Image
              source={{ uri: item.urlFoto }}
              style={{ height: 200, width: null, flex: 1 }}
            />
          </CardItem>
          <CardItem>
            <Left>
              <Button transparent>
                <Icon style={Styles.icon} name="phone" type="FontAwesome" />
                <Text style={Styles.label}>{item.telefone}</Text>
              </Button>
            </Left>
            <Right>
              <Button transparent>
                <Icon style={Styles.icon} name="comments" type="FontAwesome" />
                <Text style={Styles.label}>
                  {item.comentarios.length} Comentários
                </Text>
              </Button>
            </Right>
          </CardItem>
        </Card>
      </TouchableOpacity>
    );
  }
}
