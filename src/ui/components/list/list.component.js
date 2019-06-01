import React, { PureComponent } from 'react';
import {
  FlatList,
  View,
} from 'react-native';
import { ListItemSection } from './sections/list.item.section'

export class ListComponent extends PureComponent {

  renderItem = ({ item }) => {
    const { navigation } = this.props
    return (
      <ListItemSection
        navigation={navigation}
        item={item.response}
      />
    )
  }

  _keyExtractor(i, index) {
    return index.toString();
  }

  render() {
    const { lista, } = this.props
    return (
      <View>
        <FlatList
          data={lista}
          renderItem={this.renderItem}
          keyExtractor={this._keyExtractor}
        />
      </View>
    )
  }
}
