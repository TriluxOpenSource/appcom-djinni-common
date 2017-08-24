cmake_minimum_required (VERSION 3.6)

set(CMAKE_CXX_STANDARD 14)

# ----------------------------------------------------------------------------------------------------------------------
# General
# ----------------------------------------------------------------------------------------------------------------------

include_directories(# djinni suppport lib
                    deps/djinni/support-lib
                    deps/djinni/support-lib/objc
                    deps/djinni/support-lib/jni
                    # djinni generated code
                    generated-src/cpp
                    generated-src/objc
                    generated-src/objcpp
                    generated-src/jni
                    # implementation
                    src)

file(GLOB jni_generated_src "${CMAKE_CURRENT_LIST_DIR}/generated-src/jni/*.cpp")
file(GLOB objc_generated_src "${CMAKE_CURRENT_LIST_DIR}/generated-src/objc/*.mm")
file(GLOB objcpp_generated_src "${CMAKE_CURRENT_LIST_DIR}/generated-src/objcpp/*.mm")
file(GLOB cpp_src "${CMAKE_CURRENT_LIST_DIR}/src/*.cpp")

# ----------------------------------------------------------------------------------------------------------------------
# Boost - http://www.boost.org
# ----------------------------------------------------------------------------------------------------------------------

find_package(Boost 1.64.0 REQUIRED COMPONENTS log)

include_directories (${Boost_INCLUDE_DIRS})

# ----------------------------------------------------------------------------------------------------------------------
# cURL - https://curl.haxx.se/libcurl/
# ----------------------------------------------------------------------------------------------------------------------

find_library(curl NAMES "curl")

if(${curl} STREQUAL "curl-NOTFOUND")
    message(FATAL_ERROR "Couldn't find the curl library. Please check the Readme for required dependencies.")
else()
    message(STATUS "Found 'curl' at: ${curl}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# JNI
# ----------------------------------------------------------------------------------------------------------------------

find_package(JNI REQUIRED)

include_directories (${JNI_INCLUDE_DIRS})

# ----------------------------------------------------------------------------------------------------------------------
# nlohmann/json - https://github.com/nlohmann/json
# ----------------------------------------------------------------------------------------------------------------------

find_file(NLOHMANN_JSON "nlohmann/json.hpp")
if(NOT NLOHMANN_JSON)
  message(FATAL_ERROR "nlohmann/json is required. Please check the Readme.md for required dependencies.")
else()
  message(STATUS "Found 'nlohmann/json' at: ${NLOHMANN_JSON}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# djinni support library
# ----------------------------------------------------------------------------------------------------------------------

add_library(djinni-support-objc
            STATIC
            deps/djinni/support-lib/objc/DJIError.mm
            deps/djinni/support-lib/objc/DJIProxyCaches.mm)

add_library(djinni-support-jni
            STATIC
            deps/djinni/support-lib/jni/djinni_main.cpp
            deps/djinni/support-lib/jni/djinni_support.cpp)

set_target_properties(djinni-support-objc PROPERTIES COMPILE_FLAGS "-fobjc-arc")

# ----------------------------------------------------------------------------------------------------------------------
# appcom common microservice sdk
# ----------------------------------------------------------------------------------------------------------------------

add_library(ac-ms-common-sdk
            STATIC
            # generated objective-c++ code
            ${objcpp_generated_src}
            # generated objective-c code
            ${objc_generated_src}
            # generated jni code
            ${jni_generated_src}
            # implementation
            ${cpp_src}
            )

set_target_properties(ac-ms-common-sdk PROPERTIES COMPILE_FLAGS "-fobjc-arc")

target_link_libraries(ac-ms-common-sdk
                      djinni-support-objc
                      djinni-support-jni
                      ${curl}
                      ${Boost_LIBRARIES})

# Boost Unit Tests
find_package(Boost 1.64.0 COMPONENTS unit_test_framework)

# only enable unit tests if there is the unit test framework
if(Boost_UNIT_TEST_FRAMEWORK_FOUND)
    
    # enable cmake testing
    enable_testing()

    # add definition for appcom unit test
    add_definitions(-DAPPCOM_UNIT_TEST)

    # all tests are in the test folder
    file(GLOB TEST_SRC RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} tests/*.cpp)

    # process every test file
    foreach(testSrc ${TEST_SRC})

        # get the filename without the extension
        get_filename_component(testname ${testSrc} NAME_WE)

        # add test as executable
        add_executable(${testname} ${testSrc})

        # link jwtpp, boost and crypto++  
        target_link_libraries(${testname}
                              ac-ms-common-sdk
                              djinni-support-objc
                              djinni-support-jni
                              ${curl}
                              ${Boost_LIBRARIES})

        # save the executable in the tests folder
        set_target_properties(${testname} PROPERTIES RUNTIME_OUTPUT_DIRECTORY tests)

        # add to cmake tests
        add_test(NAME ${testname} COMMAND tests/${testname})
    endforeach(testSrc)
endif()
