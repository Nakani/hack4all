import React, { Component } from "react";
import { connect } from "react-redux";
import { maps } from "./detail.map";
import { View, Text } from "react-native";
import { Icon } from "native-base";

import {
  BaseComponent,
  CardDetailComponent,
  CommentsComponent
} from "../../../components";
import { Styles } from "./detail.style";
import { Image } from "react-native";

export class DetailScreen extends Component {
  renderImage(url) {
    return (
      <Image
        source={{ uri: url }}
        style={{ height: 200, width: null, flex: 1 }}
      />
    );
  }

  renderCard(detail) {
    const { navigation } = this.props;
    return <CardDetailComponent detail={detail} navigation={navigation} />;
  }

  adjustmentArray(comentarios) {
    const commentsArray = [];
    comentarios.map(comment => {
      commentsArray.push({
        comment
      });
    });
    return commentsArray;
  }

  renderDetail(detail) {
    return (
      <View style={{ padding: 0 }}>
        {this.renderImage(detail.urlFoto)}
        <View style={Styles.contentTitle}>
          <Text style={Styles.textTitle}>{detail.titulo}</Text>
          <View style={Styles.iconContent}>
            <Icon style={Styles.icon} name="star" type="FontAwesome" />
          </View>
        </View>
        {this.renderCard(detail)}
        <View>
          <Text style={Styles.textTitleComments}>Comentários</Text>
        </View>
        <CommentsComponent
          comments={this.adjustmentArray(detail.comentarios)}
        />
      </View>
    );
  }

  render() {
    const { navigation } = this.props;
    console.log(navigation);
    return navigation != null ? (
      <BaseComponent
        headerName={"home"}
        headerStyle={{ backgroundColor: "#E08C00" }}
        headerDisplay={true}
        headerName={
          navigation.state.params.item.cidade +
          " - " +
          navigation.state.params.item.bairro
        }
        goback={true}
        navigation={navigation}
      >
        {this.renderDetail(navigation.state.params.item)}
      </BaseComponent>
    ) : null;
  }
}

export const DetailScreenConnected = connect(
  maps.mapStateToProps,
  maps.mapDispatchToProps
)(DetailScreen);
