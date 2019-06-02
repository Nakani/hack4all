import React, { Component } from "react";
import { connect } from "react-redux";
import { maps } from "./comanda.map";
import PropTypes from "prop-types";
import { View, Vibration } from "react-native";
import { RNCamera } from "react-native-camera";
import { styleView, styleCamera } from "./comanda.style";
import {
  loadingTab,
  receiveTab,
  getTabDetails,
  cancelCameraAccess,
  activateCamera
} from "../../../reduxs";

export class ComandaScreen extends Component {
  static propTypes = {
    onRead: PropTypes.func.isRequired,
    reactivate: PropTypes.bool,
    reactivateTimeout: PropTypes.number
  };

  static defaultProps = {
    onRead: data => console.log(data.data),
    reactivate: true,
    reactivateTimeout: 1000
  };

  constructor(props) {
    super(props);

    this.state = {
      scanning: false,
      flash: "off"
    };
    this.timeout = null;
    this._handleBarCodeRead = this._handleBarCodeRead.bind(this);
  }

  componentDidMount() {
    const { navigation } = this.props;
    this.lista("55");
    this.subs = [
      navigation.addListener("didFocus", () => this._setScanning(false)),
      navigation.addListener("willBlur", () => this._componentWillUnmount())
    ];
  }

  async lista(id) {
    console.log("inicio");
    const data = await getTabDetails(id);
    console.log(data);
  }

  _componentWillUnmount() {
    this.setState({ scanning: true, flash: "off" });
  }
  _setScanning(value) {
    this.setState({ scanning: value });
  }

  _handleBarCodeRead(e) {
    if (!this.state.scanning) {
      Vibration.vibrate();
      this._setScanning(true);
      this.props.onRead(e);
    }
  }

  toggleFlash() {
    this.setState({
      flash: flashModeOrder[this.state.flash]
    });
  }

  _renderScanArea() {
    return (
      <View
        style={styleView.scanArea}
        accessibilityLabel="QRCodeScannerScanArea"
      />
    );
  }

  render() {
    const { navigation } = this.props;
    return (
      <RNCamera
        style={styleCamera.container}
        accessibilityLabel="qRCodeScanner"
        flashMode={this.state.flash}
        onBarCodeRead={this._handleBarCodeRead.bind(this)}
        captureAudio={false}
      >
        <View
          style={styleView.contentScan}
          accessibilityLabel="viewScanAreaQRCode"
        >
          <View
            style={styleView.margin}
            accessibilityLabel="viewMarginCloseQRCodeTop"
          />
          {this._renderScanArea()}
          <View
            style={styleView.margin}
            accessibilityLabel="viewMarginCloseQRCodeBottom"
          />
        </View>
      </RNCamera>
    );
  }
}

const mapStateToProps = state => ({
  tab: state.tab
});

const mapDispatchToProps = dispatch => ({
  loadingTab: () => dispatch(loadingTab()),
  receiveTab: () => dispatch(receiveTab()),
  getTabDetails: id => dispatch(getTabDetails(id)),
  cancelCameraAccess: () => dispatch(cancelCameraAccess()),
  activateCamera: () => dispatch(activateCamera())
});

export const ComandaScreenConnected = connect(
  mapStateToProps,
  mapDispatchToProps
)(ComandaScreen);
