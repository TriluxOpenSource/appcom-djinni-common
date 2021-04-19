from conans import ConanFile, CMake, tools
import os

class DjinniCommonConan(ConanFile):
    name = "appcom-djinni-common"
    version = "1.0.4"
    author = "Ralph-Gordon Paul (g.paul@appcom-interactive.de)"
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "android_ndk": "ANY", 
        "android_stl_type":["c++_static", "c++_shared"]}
    default_options = "shared=False", "android_ndk=None", "android_stl_type=c++_static"
    description = "This library contains functions that are commonly used in appcom djinni projects."
    url = "https://github.com/appcom-interactive/appcom-djinni-common"
    license = "MIT"
    exports_sources = "src/*", "CMakeLists.txt", "bin/*", "djinni/*", "run-djinni.sh"
    generators = "cmake"

    # compile using cmake
    def build(self):
        cmake = CMake(self)
        library_folder = self.source_folder
        cmake.verbose = True

        self.run("./run-djinni.sh")

        if self.settings.os == "Android":
            self.applyCmakeSettingsForAndroid(cmake)

        if self.settings.os == "iOS":
            self.applyCmakeSettingsForiOS(cmake)

        if self.settings.os == "Macos":
            self.applyCmakeSettingsFormacOS(cmake)

        # build static library if shared option is disabled
        cmake.definitions["BUILD_STATIC_LIB"] = "OFF" if self.options.shared else "ON"

        cmake.configure(source_folder=library_folder)
        cmake.build()
        cmake.install()

    def applyCmakeSettingsForAndroid(self, cmake):
        android_toolchain = os.environ["ANDROID_NDK_PATH"] + "/build/cmake/android.toolchain.cmake"
        cmake.definitions["CMAKE_TOOLCHAIN_FILE"] = android_toolchain
        cmake.definitions["ANDROID_NDK"] = os.environ["ANDROID_NDK_PATH"]
        cmake.definitions["ANDROID_ABI"] = tools.to_android_abi(self.settings.arch)
        cmake.definitions["ANDROID_STL"] = self.options.android_stl_type
        cmake.definitions["ANDROID_NATIVE_API_LEVEL"] = self.settings.os.api_level
        cmake.definitions["ANDROID_TOOLCHAIN"] = "clang"
        cmake.definitions["DJINNI_WITH_JNI"] = "ON"

    def applyCmakeSettingsForiOS(self, cmake):
        cmake.definitions["CMAKE_SYSTEM_NAME"] = "iOS"
        cmake.definitions["DEPLOYMENT_TARGET"] = "10.0"
        cmake.definitions["CMAKE_OSX_DEPLOYMENT_TARGET"] = "10.0"
        cmake.definitions["CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH"] = "NO"
        cmake.definitions["CMAKE_IOS_INSTALL_COMBINED"] = "YES"
        cmake.definitions["DJINNI_WITH_OBJC"] = "ON"
        
        # define all architectures for ios fat library
        if "arm" in self.settings.arch:
            cmake.definitions["CMAKE_OSX_ARCHITECTURES"] = "armv7;armv7s;arm64;arm64e"
        else:
            cmake.definitions["CMAKE_OSX_ARCHITECTURES"] = tools.to_apple_arch(self.settings.arch)

    def applyCmakeSettingsFormacOS(self, cmake):
        cmake.definitions["CMAKE_OSX_ARCHITECTURES"] = tools.to_apple_arch(self.settings.arch)
        cmake.definitions["DJINNI_WITH_OBJC"] = "ON"
        
    def package_info(self):
        self.cpp_info.libs = tools.collect_libs(self)
        self.cpp_info.includedirs = ['include']

    def package_id(self):
        if "arm" in self.settings.arch and self.settings.os == "iOS":
            self.info.settings.arch = "AnyARM"

    def requirements(self):
        self.requires("boost/1.70.0@%s/%s" % (self.user, self.channel))
        self.requires("djinni/470@%s/%s" % (self.user, self.channel))
        self.requires("nlohmann-json/3.6.1@%s/%s" % (self.user, self.channel))

    def configure(self):
        if self.settings.os == "Android":
            self.options["boost"].shared = False
            self.options["boost"].android_ndk = self.options.android_ndk
            self.options["boost"].android_stl_type = self.options.android_stl_type

            self.options["djinni"].shared = self.options.shared
            self.options["djinni"].android_ndk = self.options.android_ndk
            self.options["djinni"].android_stl_type = self.options.android_stl_type

    def config_options(self):
        # remove android specific option for all other platforms
        if self.settings.os != "Android":
            del self.options.android_ndk
            del self.options.android_stl_type
