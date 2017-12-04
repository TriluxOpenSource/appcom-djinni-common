cmake_minimum_required (VERSION 3.6)

set(CMAKE_CXX_STANDARD 14)

if (NOT ANDROID)
  message (FATAL_ERROR "This CMake Project is only for Android.")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# General
# ----------------------------------------------------------------------------------------------------------------------

set(CMAKE_CXX_FLAGS "-Wall -fexceptions -frtti")
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../cmake")

include_directories(# djinni support library
                    ${CMAKE_CURRENT_SOURCE_DIR}/include/djinni/jni
                    # android deps
                    "${CMAKE_CURRENT_LIST_DIR}/include"
                    # djinni generated
                    "${CMAKE_CURRENT_LIST_DIR}/../generated-src/jni"
                    "${CMAKE_CURRENT_LIST_DIR}/../generated-src/cpp"
                    # implementation
                    "${CMAKE_CURRENT_LIST_DIR}/../src")

# djinni generated code
file(GLOB jni_generated_src "${CMAKE_CURRENT_LIST_DIR}/../generated-src/jni/*.cpp")
file(GLOB jni_generated_headers "${CMAKE_CURRENT_LIST_DIR}/../generated-src/jni/*.hpp")
file(GLOB cpp_generated_headers "${CMAKE_CURRENT_LIST_DIR}/../generated-src/cpp/*.hpp")

# implementation
file(GLOB cpp_src "${CMAKE_CURRENT_LIST_DIR}/../src/cpp/*.cpp")
file(GLOB cpp_headers "${CMAKE_CURRENT_LIST_DIR}/../src/cpp/*.hpp")

# ----------------------------------------------------------------------------------------------------------------------
# Boost - http://www.boost.org
# ----------------------------------------------------------------------------------------------------------------------

message(STATUS "BOOST: ${CMAKE_CURRENT_LIST_DIR}/include")
set(BOOST_INCLUDEDIR "${CMAKE_CURRENT_LIST_DIR}/include")
set(BOOST_LIBRARYDIR "${CMAKE_CURRENT_LIST_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}")
set(BOOST_ROOT "${CMAKE_CURRENT_LIST_DIR}")
set(Boost_NO_SYSTEM_PATHS ON)

message(STATUS "BOOST_INCLUDEDIR = ${BOOST_INCLUDEDIR}")
message(STATUS "BOOST_LIBRARYDIR = ${BOOST_LIBRARYDIR}")

set(Boost_USE_STATIC_LIBS ON)

#find_package(Boost 1.64.0 REQUIRED COMPONENTS log PATHS "${CMAKE_CURRENT_LIST_DIR}/../cmake" NO_DEFAULT_PATH)
find_package(Boost REQUIRED COMPONENTS log log_setup system thread filesystem)

# ----------------------------------------------------------------------------------------------------------------------
# cURL - https://curl.haxx.se/libcurl/
# ----------------------------------------------------------------------------------------------------------------------

find_library(curl NAMES curl PATHS "${CMAKE_CURRENT_LIST_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}" NO_DEFAULT_PATH)
if(${curl} STREQUAL "curl-NOTFOUND")
    message(FATAL_ERROR "Couldn't find the curl library. Please check the Readme for required dependencies.")
else()
    message(STATUS "Found 'curl' at: ${curl}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# nlohmann/json - https://github.com/nlohmann/json
# ----------------------------------------------------------------------------------------------------------------------

find_file(NLOHMANN_JSON "nlohmann/json.hpp" PATHS "${CMAKE_CURRENT_LIST_DIR}/include" NO_DEFAULT_PATH)
if(NOT NLOHMANN_JSON)
  message(FATAL_ERROR "nlohmann/json is required. Please check the Readme.md for required dependencies.")
else()
  message(STATUS "Found 'nlohmann/json' at: ${NLOHMANN_JSON}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# djinni support library
# ----------------------------------------------------------------------------------------------------------------------

find_library(djinni NAMES djinni-support PATHS "${CMAKE_CURRENT_LIST_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}" 
             NO_DEFAULT_PATH)
if(${djinni} STREQUAL "djinni-NOTFOUND")
    message(FATAL_ERROR "Couldn't find the djinni library. Please check the Readme for required dependencies.")
else()
    message(STATUS "Found 'djinni' at: ${djinni}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# appcom common microservice sdk
# ----------------------------------------------------------------------------------------------------------------------

add_library(ac-ms-common-sdk
            SHARED
            # generated code
            ${jni_generated_src}
            # implementation
            ${cpp_src}
            )

target_link_libraries(ac-ms-common-sdk
                      ${djinni}
                      ${curl}
                      ${Boost_LIBRARIES}
                      android
                      log)

set_target_properties(ac-ms-common-sdk PROPERTIES COMPILE_FLAGS "-fPIC")

install(TARGETS ac-ms-common-sdk
        LIBRARY DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/lib/${CMAKE_ANDROID_ARCH_ABI}")

install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/../generated-src/java/eu"
        DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/jni/")

install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/../src/android/eu"
        DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/jni/")

install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/../src/java/eu"
        DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/jni/")

install(FILES ${jni_generated_headers} ${cpp_generated_headers} ${cpp_headers}
        DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/include/appcom/sdk/common")
