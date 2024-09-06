# MITEK VideoCall SDK

<!--BEGIN_DESCRIPTION-->
Make an video call to MITEK ecosystem easily
<!--END_DESCRIPTION-->

## Supported platforms

MITEK VideoCall SDK for Flutter is designed to work across all platforms supported by Flutter:

- Android
- iOS
- Web
- macOS
- Windows
- Linux

## Example app

We built a multi-user conferencing app as an example in the [example/](example/) folder. LiveKit is compatible cross-platform: you could join the same room using any of our supported realtime SDKs.

### iOS

Camera and microphone usage need to be declared in your `Info.plist` file.

```xml
<dict>
  ...
  <key>NSCameraUsageDescription</key>
  <string>$(PRODUCT_NAME) uses your camera</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>$(PRODUCT_NAME) uses your microphone</string>
```

Your application can still run the voice call when it is switched to the background if the background mode is enabled. Select the app target in Xcode, click the Capabilities tab, enable Background Modes, and check **Audio, AirPlay, and Picture in Picture**.

Your `Info.plist` should have the following entries.

```xml
<dict>
  ...
  <key>UIBackgroundModes</key>
  <array>
    <string>audio</string>
  </array>
```

#### Notes

Since [xcode 14](https://developer.apple.com/news/upcoming-requirements/?id=06062022a) no longer supports 32bit builds, and our latest version is based on libwebrtc m104+ the iOS framework no longer supports 32bit builds, we strongly recommend upgrading to flutter 3.3.0+. if you are using flutter 3.0.0 or below, there is a high chance that your flutter app cannot be compiled correctly due to the missing i386 and arm 32bit framework [#132](https://github.com/livekit/client-sdk-flutter/issues/132) [#172](https://github.com/livekit/client-sdk-flutter/issues/172).

You can try to modify your `{projects_dir}/ios/Podfile` to fix this issue.

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|

      # Workaround for https://github.com/flutter/flutter/issues/64502
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES' # <= this line

    end
  end
end
```

For iOS, the minimum supported deployment target is `13.0`. You will need to add the following to your Podfile.

```ruby
platform :ios, '13.0'
```

You may need to delete `Podfile.lock` and re-run `pod install` after updating deployment target.

### Android

We require a set of permissions that need to be declared in your `AppManifest.xml`. These are required by Flutter WebRTC, which we depend on.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.your.package">
  <uses-feature android:name="android.hardware.camera" />
  <uses-feature android:name="android.hardware.camera.autofocus" />
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
  <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
  <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
  ...
</manifest>
```
