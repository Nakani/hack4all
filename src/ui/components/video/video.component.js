import React, { PureComponent } from "react";
import { View, Text, Image, TouchableOpacity } from "react-native";
import Video from "react-native-video";
import { Styles } from "./video.style";

export class VideoComponent extends PureComponent {
  render() {
    return (
      <Video
        source={require("../../../assets/videoHome.mp4")}
        muted={true}
        repeat={true}
        resizeMode={"cover"}
        rate={1.0}
        ignoreSilentSwitch={"obey"}
        style={Styles.backgroundVideo}
      />
    );
  }
}
