import React, { Component } from "react";
import { connect } from "react-redux";
import { maps } from "./home.map";
import { ListComponent, BaseComponent } from "../../components";

export class HomeScreen extends Component {
  renderLists(lists) {
    const { navigation } = this.props;
    return <ListComponent lista={lists} navigation={navigation} />;
  }

  render() {
    const { lists, navigation } = this.props;
    return (
      <BaseComponent
        headerName={"home"}
        headerDisplay={false}
        headerName={navigation.state.routeName}
      >
        {this.renderLists(lists)}
      </BaseComponent>
    );
  }
}

export const HomeScreenConnected = connect(
  maps.mapStateToProps,
  maps.mapDispatchToProps
)(HomeScreen);
