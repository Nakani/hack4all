import React, { PureComponent } from 'react';
import { Text, View, ScrollView, FlatList } from 'react-native';
import { ListCommentsSection } from './section/listComments.section'
export class CommentsComponent extends PureComponent {

  renderItem(comment) {
    return (
      <View>
        <ListCommentsSection
          comment={comment.item.comment}
        />
      </View>
    )
  }

  _keyExtractor(i, index) {
    return index.toString();
  }

  render() {
    const { comments, } = this.props
    return (
      <View>
        <FlatList
          data={comments}
          renderItem={this.renderItem}
          keyExtractor={this._keyExtractor}
        />
      </View>
    )
  }
}
