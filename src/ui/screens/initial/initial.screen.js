import React, { Component } from "react";
import { connect } from "react-redux";
import { maps } from "./initial.map";
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
      <BaseComponent
        headerName={"home"}
        headerStyle={{ backgroundColor: "#E08C00" }}
        headerDisplay={true}
        headerName={navigation.state.routeName}
      >
        {this.renderLists(lists)}
      </BaseComponent>
    );
  }
}

export const InitialScreenConnected = connect(
  maps.mapStateToProps,
  maps.mapDispatchToProps
)(InitialScreen);
