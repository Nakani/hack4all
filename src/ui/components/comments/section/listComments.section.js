import React, { PureComponent } from "react";
import { Text, View, FlatList } from "react-native";
import {
  List,
  ListItem,
  Left,
  Body,
  Right,
  Thumbnail,
  Icon
} from "native-base";
import { Styles } from "./listComments.style";

export class ListCommentsSection extends PureComponent {
  renderStarIcon() {
    return <Icon style={Styles.icon} name="star" type="FontAwesome" />;
  }

  renderNote(note) {
    const star = [];
    for (let i = 0; i < note; i++) {
      star.push(<Icon style={Styles.icon} name="star" type="FontAwesome" />);
    }
    return star;
  }

  render() {
    const { comment } = this.props;
    return (
      <View>
        <List>
          <ListItem avatar>
            <Left>
              <Thumbnail source={{ uri: comment.urlFoto }} />
            </Left>
            <Body>
              <Text style={Styles.name}>{comment.nome}</Text>
              <Text style={Styles.title}>{comment.titulo}</Text>
              <Text style={Styles.comment} note>
                {comment.comentario}
              </Text>
            </Body>
            <Right>
              <Text note>{this.renderNote(comment.nota)}</Text>
            </Right>
          </ListItem>
        </List>
      </View>
    );
  }
}
