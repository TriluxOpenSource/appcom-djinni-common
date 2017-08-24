cmake_minimum_required (VERSION 3.6)

set(CMAKE_CXX_STANDARD 14)

if (NOT IOS)
  message (FATAL_ERROR "This CMake Project is only for iOS.")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# General
# ----------------------------------------------------------------------------------------------------------------------

include_directories(# djinni suppport lib
                    ../deps/djinni/support-lib
                    ../deps/djinni/support-lib/objc
                    # djinni generated code
                    ../generated-src/cpp
                    ../generated-src/objc
                    ../generated-src/objcpp
                    # other deps
                    ${CMAKE_CURRENT_SOURCE_DIR}/include
                    # our source
                    ../src)

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

file(GLOB objc_generated_src "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objc/*.mm")
file(GLOB objc_generated_headers "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objc/*.h")
file(GLOB objcpp_generated_src "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objcpp/*.mm")
file(GLOB cpp_src "${CMAKE_CURRENT_LIST_DIR}/../src/*.cpp")
file(GLOB cpp_headers "${CMAKE_CURRENT_LIST_DIR}/../src/*.hpp")

# ----------------------------------------------------------------------------------------------------------------------
# Boost - http://www.boost.org
# ----------------------------------------------------------------------------------------------------------------------

set(BOOST_INCLUDEDIR "${CMAKE_CURRENT_LIST_DIR}/include")
set(BOOST_LIBRARYDIR "${CMAKE_CURRENT_LIST_DIR}/lib")
set(BOOST_ROOT "${CMAKE_CURRENT_LIST_DIR}")

message(STATUS "BOOST_INCLUDEDIR = ${BOOST_INCLUDEDIR}")
message(STATUS "BOOST_LIBRARYDIR = ${BOOST_LIBRARYDIR}")

set(Boost_USE_STATIC_LIBS ON)

find_package(Boost 1.64.0 REQUIRED COMPONENTS log)

# ----------------------------------------------------------------------------------------------------------------------
# cURL - https://curl.haxx.se/libcurl/
# ----------------------------------------------------------------------------------------------------------------------

#find_library(curl NAMES curl PATHS "${CMAKE_CURRENT_LIST_DIR}/lib")
find_library(curl NAMES curl PATHS "${CMAKE_CURRENT_LIST_DIR}/lib" NO_DEFAULT_PATH)
if(${curl} STREQUAL "curl-NOTFOUND")
    message(FATAL_ERROR "Couldn't find the curl library. Please check the Readme for required dependencies.")
else()
    message(STATUS "Found 'curl' at: ${curl}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# nlohmann/json - https://github.com/nlohmann/json
# ----------------------------------------------------------------------------------------------------------------------

find_file(NLOHMANN_JSON "nlohmann/json.hpp" HINTS "${CMAKE_CURRENT_LIST_DIR}/include")
if(NOT NLOHMANN_JSON)
  message(FATAL_ERROR "nlohmann/json is required. Please check the Readme.md for required dependencies.")
else()
  message(STATUS "Found 'nlohmann/json' at: ${NLOHMANN_JSON}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# djinni support library
# ----------------------------------------------------------------------------------------------------------------------

add_library(djinni-support
            STATIC
            ../deps/djinni/support-lib/objc/DJIError.mm
            ../deps/djinni/support-lib/objc/DJIProxyCaches.mm)

set_target_properties(djinni-support PROPERTIES COMPILE_FLAGS "-fobjc-arc")

# ----------------------------------------------------------------------------------------------------------------------
# appcom common microservice sdk
# ----------------------------------------------------------------------------------------------------------------------

add_library(ac-ms-common-sdk
            STATIC
            # generated objective-c++ code
            ${objc_generated_src}
            # generated objective-c code
            ${objcpp_generated_src}
            # implementation
            ${cpp_src}
            )

set_target_properties(ac-ms-common-sdk PROPERTIES COMPILE_FLAGS "-fobjc-arc")

target_link_libraries(ac-ms-common-sdk
                      djinni-support
                      ${curl}
                      ${Boost_LIBRARIES})

install(TARGETS ac-ms-common-sdk djinni-support
        LIBRARY DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/lib/"
        ARCHIVE DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/lib/")

install(FILES ${objc_generated_headers} ${cpp_headers}
        DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/include/")
