import React, { Component } from 'react';
import { View, Image } from 'react-native'
import { BaseComponent } from '../../components'
import { Styles } from './services.style'
import { Card, CardItem, Thumbnail, Text, Button, Icon, Left, Body, Right } from 'native-base';

export class ServicesScreen extends Component {

  render() {
    const { lists, navigation } = this.props
    return (
      <BaseComponent
        headerName={'home'}
        headerStyle={{ backgroundColor: "#E08C00" }}
        headerDisplay={true}
        goback={true}
        headerName={'Serviços'}
        navigation={navigation}
      >
        <Card>
          <CardItem>
            <Left>
              <Body>
                <Text style={Styles.labelTitleCard}>Gastromia</Text>
              </Body>
            </Left>
          </CardItem>
          <CardItem cardBody>
            <Image source={{ uri: 'http://amelhorcoisadaminhavida.com.br/wp-content/uploads/2017/11/iStock_congreso-gastronomia-nosotros-2.jpg' }}
              style={{ height: 200, width: null, flex: 1 }} />
          </CardItem>
          <CardItem>
            <Left>
              <Button transparent>
                <Icon
                  style={Styles.labelTitlebuttoms}
                  active name="thumbs-up" />
                <Text style={Styles.labelTitleCard}>12 Curtidas</Text>
              </Button>
            </Left>
            <Right>
              <Button transparent>
                <Icon
                  style={Styles.labelTitlebuttoms}
                  active name="chatbubbles" />
                <Text style={Styles.labelTitleCard}>4 comentarios</Text>
              </Button>
            </Right>
          </CardItem>
        </Card>

        <Card>
          <CardItem>
            <Left>
              <Body>
                <Text style={Styles.labelTitleCard}>Turismo</Text>
              </Body>
            </Left>
          </CardItem>
          <CardItem cardBody>
            <Image source={{ uri: 'https://www.rbsdirect.com.br/imagesrc/24158513.jpg?w=700' }}
              style={{ height: 200, width: null, flex: 1 }} />
          </CardItem>
          <CardItem>
            <Left>
              <Button transparent>
                <Icon
                  style={Styles.labelTitlebuttoms}
                  active name="thumbs-up" />
                <Text style={Styles.labelTitleCard}>30 Curtidas</Text>
              </Button>
            </Left>
            <Right>
              <Button transparent>
                <Icon
                  style={Styles.labelTitlebuttoms}
                  active name="chatbubbles" />
                <Text style={Styles.labelTitleCard}>8 comentarios</Text>
              </Button>
            </Right>
          </CardItem>
        </Card>
        <Card>
          <CardItem>
            <Left>
              <Body>
                <Text style={Styles.labelTitleCard}>Shows</Text>
              </Body>
            </Left>
          </CardItem>
          <CardItem cardBody>
            <Image source={{ uri: 'https://cdn.reweb.io/hagah/image/yiCH90ukmtf_6vpRRUp5wYE62Yo=/1024x/top/smart/hagah/1/1d/7-casas-para-assistir-shows-em-porto-alegre-1d9b8558.jpg' }}
              style={{ height: 200, width: null, flex: 1 }} />
          </CardItem>
          <CardItem>
            <Left>
              <Button transparent>
                <Icon
                  style={Styles.labelTitlebuttoms}
                  active name="thumbs-up" />
                <Text style={Styles.labelTitleCard}>30 Curtidas</Text>
              </Button>
            </Left>
            <Right>
              <Button transparent>
                <Icon
                  style={Styles.labelTitlebuttoms}
                  active name="chatbubbles" />
                <Text style={Styles.labelTitleCard}>8 comentarios</Text>
              </Button>
            </Right>
          </CardItem>
        </Card>

      </BaseComponent>
    );
  }
}
