import React, { PureComponent } from "react";
import { SafeAreaView } from "react-native";
import { Container, Content } from "native-base";
import { HeaderComponent } from "../header/header.component";
import { Theme } from "../../../config/theme";

export class BaseComponent extends PureComponent {
  render() {
    const { children, ...rest } = this.props;
    return rest.headerDisplay ? (
      <Container style={{ backgroundColor: Theme.BackgroundColor.base }}>
        <HeaderComponent
          headerName={rest.headerName}
          headerStyle={rest.headerStyle}
          goback={rest.goback}
          navigation={rest.navigation}
        />
        <Content>{children}</Content>
      </Container>
    ) : (
      <Container style={{ backgroundColor: Theme.BackgroundColor.base }}>
        <Content>{children}</Content>
      </Container>
    );
  }
}
