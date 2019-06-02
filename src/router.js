import React from "react";
import {
  createBottomTabNavigator,
  createStackNavigator,
  createSwitchNavigator,
  createAppContainer
} from "react-navigation";
import { Platform } from "react-native";
import { Icon } from "native-base";
import { Theme } from "./config/theme";
import {
  HomeScreenConnected,
  InitialScreen,
  LoginScreen,
  ComandaScreenConnected
} from "./ui/screens";
import { HeaderComponent } from "./ui/components";

const navConfig = navigation => ({
  headerForceInset: {
    top: "never"
  },
  headerTitle: <HeaderComponent navigation={navigation} />,
  headerLeft: null,
  headerStyle: {
    borderBottomWidth: 0,
    ...Platform.select({
      android: {
        //shadowColor: COLORS.$transparent,
        shadowOpacity: 0,
        shadowRadius: 0,
        shadowOffset: {
          height: 0,
          width: 0
        },
        elevation: 0
      }
    })
  }
});

const HomeStack = createStackNavigator({
  Home: {
    screen: HomeScreenConnected,
    navigationOptions: {
      header: null
    }
  }
});
const ComandaStack = createStackNavigator({
  Comanda: {
    screen: ComandaScreenConnected,
    navigationOptions: {
      header: null
    }
  }
});

const InitialStack = createStackNavigator({
  Perfil: {
    screen: InitialScreen,
    navigationOptions: {
      header: null
    }
  }
});

const LoginStack = createStackNavigator({
  Login: {
    screen: LoginScreen,
    navigationOptions: {
      header: null
    }
  }
});

const getTabBarIcon = (navigation, focused, tintColor) => {
  const { routeName } = navigation.state;
  let iconName;
  switch (routeName) {
    case "Home":
      iconName = "home";
      break;
    case "Comanda":
      iconName = "qrcode";
      break;
    case "Perfil":
      iconName = "user-circle-o";
      break;
  }
  return (
    <Icon
      name={iconName}
      style={{ fontSize: 35, color: tintColor }}
      type="FontAwesome"
    />
  );
};

const TabNavigator = createBottomTabNavigator(
  {
    Home: HomeStack,
    Comanda: ComandaStack,
    Perfil: InitialStack
  },
  {
    defaultNavigationOptions: ({ navigation }) => ({
      tabBarIcon: ({ focused, tintColor }) =>
        getTabBarIcon(navigation, focused, tintColor)
    }),
    tabBarOptions: {
      tinColor: Theme.Colors.orange,
      activeTintColor: Theme.Colors.orange,
      inactiveTintColor: "#fff",
      showIcon: true,
      showLabel: false,
      lazyLoad: true,
      upperCaseLabel: false,
      indicatorStyle: {
        backgroundColor: "transparent"
      },
      style: {
        backgroundColor: "rgba(51, 51, 51, 0.3)",
        borderTopWidth: 0,
        position: "absolute",
        left: 0,
        right: 0,
        bottom: 0
      }
    }
  }
);

const AppStack = createStackNavigator({
  Login: {
    screen: LoginStack,
    navigationOptions: {
      header: null
    }
  },
  Home: {
    screen: TabNavigator,
    navigationOptions: {
      header: null
    }
  }
});

export const AppNavigator = createSwitchNavigator(
  {
    App: AppStack
  },
  {
    initialRouteName: "App"
  }
);

const AppContainer = createAppContainer(AppNavigator);

export default AppContainer;
