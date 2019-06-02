package com.gastronomymodule;

import android.app.Application;

import com.facebook.react.ReactApplication;
import org.reactnative.camera.RNCameraPackage;
import com.brentvatne.react.ReactVideoPackage;
import com.swmansion.gesturehandler.react.RNGestureHandlerPackage;
import com.geektime.rnonesignalandroid.ReactNativeOneSignalPackage;
import com.dylanvann.fastimage.FastImageViewPackage;
import com.kevinresol.react_native_default_preference.RNDefaultPreferencePackage;
import com.learnium.RNDeviceInfo.RNDeviceInfo;
import com.BV.LinearGradient.LinearGradientPackage;
import com.fourall.gastronomymodule.GastronomyNativePackage;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
            new RNCameraPackage(),
            new ReactVideoPackage(),
            new RNGestureHandlerPackage(),
            new ReactNativeOneSignalPackage(),
            new FastImageViewPackage(),
            new RNDefaultPreferencePackage(),
            new RNDeviceInfo(),
            new LinearGradientPackage(),
            new GastronomyNativePackage()
      );
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);
  }
}
