import React, { PureComponent } from "react";
import { SafeAreaView, View } from "react-native";
import { Container, Content } from "native-base";
import { HeaderComponent } from "../header/header.component";
import { Theme } from "../../../config/theme";

export class BaseComponent extends PureComponent {
  render() {
    const { children, ...rest } = this.props;
    return rest.headerDisplay ? (
      <SafeAreaView
        style={{ flex: 1, backgroundColor: Theme.BackgroundColor.base }}
      >
        <Container style={{ backgroundColor: Theme.BackgroundColor.base }}>
          <HeaderComponent
            headerName={rest.headerName}
            headerStyle={rest.headerStyle}
            goback={rest.goback}
            navigation={rest.navigation}
          />
          <Content>{children}</Content>
        </Container>
      </SafeAreaView>
    ) : (
      <SafeAreaView
        style={{ flex: 1, backgroundColor: Theme.BackgroundColor.base }}
      >
        <View
          style={[
            rest.containerStyle,
            { backgroundColor: Theme.BackgroundColor.base }
          ]}
        >
          {children}
        </View>
      </SafeAreaView>
    );
  }
}
