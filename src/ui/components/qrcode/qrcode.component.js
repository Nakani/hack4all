import React, { PureComponent } from "react";
import {
  View,
  StyleSheet,
  Text,
  Vibration,
  TouchableOpacity,
  Image
} from "react-native";
import PropTypes from "prop-types";

export class QRCodeComponent extends PureComponent {
  static propTypes = {
    onRead: PropTypes.func.isRequired,
    reactivate: PropTypes.bool,
    reactivateTimeout: PropTypes.number
  };

  static defaultProps = {
    onRead: () => console.log("QR code scanned!"),
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
    console.log("componente entrando");
    const { navigation } = this.props;
    this.subs = [
      navigation.addListener("didFocus", () => this._setScanning(false)),
      navigation.addListener("willBlur", () => this._componentWillUnmount())
    ];
  }

  _componentWillUnmount() {
    console.log("componente saindo");
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

  render() {
    console.log("qrcode");
    return (
      <View>
        <Text>QRCode</Text>
      </View>
    );
  }
}
