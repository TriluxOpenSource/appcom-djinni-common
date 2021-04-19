# appcom djinni common

This library contains functions that are commonly used in appcom djinni projects.

## Dependencies

The following libraries must be installed in the corresponding folder for the target platform (`android` for Android and 
`ios` for iOS). All libraries should be added as static libraries to keep the artifacts at a reasonable size (except the
djinni support library for Android).
The header files must be placed under `android/include` or `ios/include` and the library files must be added to
`android/lib/$ARCH$` or `ios/lib`, depending on the target platform. For Android there must be a subfolder ($ARCH$) for 
each architecture (`arm64-v8a`, `armeabi-v7a`, `x86` and `x86_64`).

* [Boost](https://www.boost.org) 1.70.0
* [Niels Lohmann JSON](https://github.com/nlohmann/json) 3.6.1
* [Dropdbox Djinni](https://github.com/dropbox/djinni)

### Dropbox Djinni

Dropbox djinni is required to be present at `deps/djinni`. This can be achieved via a git submodule:

```
git submodule add git@github.com:dropbox/djinni.git deps/djinni/
```

## Build tools

To be able to build the library the following tools must be present.

* Android SDK - https://developer.android.com/studio/index.html
* Android NDK - https://developer.android.com/ndk/downloads/index.html
* CMake - https://cmake.org

### iOS

* Xcode - https://developer.apple.com/xcode/
* CMake - https://cmake.org


## Building

To build the library the build script for the target platform can be executed (`build-android.sh` or `build-ios.sh`).
For Android, the environmental ANDROID_NDK must be set to the path of the android ndk.
