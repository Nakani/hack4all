import { StyleSheet } from 'react-native'
export const Styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#E08C00',
  },
  contentTitle: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },

  textTitle: {
    color: '#E08C00',
    padding: 10,
    fontSize: 30,
    textTransform: 'uppercase'
  },
  textTitleComments: {
    color: '#E08C00',
    padding: 5,
    fontSize: 20,
  },
  contentMaps: {
    paddingLeft: 4,
    paddingRight: 4,
  },
  map: {
    width: '100%',
    height: 200
  },
  contentEndereco: {
    flex: 1,
    backgroundColor: '#E08C00',
    alignItems: 'flex-end',
    padding: 5,
  },
  labelEndereco: {
    color: '#fff'
  },
  iconContent: {
    backgroundColor: '#E08C00',
    margin: 10,
    width: 70,
    height: 70,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 50,
    position: 'absolute',
    right: 0,
    bottom: 20
  },
  icon: {
    color: '#fff',
    fontSize: 50
  }
});

