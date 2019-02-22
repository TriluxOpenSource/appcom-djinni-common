# appcom djinni common

This library contains functions that are commonly used in appcom djinni projects.

## Dependencies

* [Boost](https://www.boost.org) 1.67
* [Niels Lohmann JSON](https://github.com/nlohmann/json) 3.1.2
* [Dropdbox Djinni](https://github.com/dropbox/djinni)

## Build

## Dependencies

The djinni sources from [Github](https://github.com/dropbox/djinni) must be placed under `deps/djinni`.

Android Libraries must be placed unter `android/lib/$ARCH$` where `$ARCH$` must be `arm64-v8a`, `armeabi-v7a`, `x86` and 
`x86_64`. The Header files must be placed under `android/include`.

iOS Libraries must be placed unter `ios/lib`. The Header files must be placed under `ios/include`.

### Building for iOS

Execute `build-ios.sh` to build for iOS.

### Building for Android

Execute `build-android.sh` to build for Android.
