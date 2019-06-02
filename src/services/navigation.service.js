import { StackActions, NavigationActions } from "react-navigation";

export class navigationService {
  static goBack(instance) {
    instance.props.navigation.pop();
  }

  static goTo(instance, screen, params = []) {
    instance.props.navigation.navigate(screen, params);
  }

  static resetStack(instance, routeName) {
    const navigateAction = StackActions.reset({
      index: 0,
      actions: [NavigationActions.navigate({ routeName })]
    });

    instance.props.navigation.dispatch(navigateAction);
  }
}
