cmake_minimum_required (VERSION 3.6)

set(CMAKE_CXX_STANDARD 14)

# ----------------------------------------------------------------------------------------------------------------------
# General
# ----------------------------------------------------------------------------------------------------------------------

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

# djinni generated code
file(GLOB objc_generated_src "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objc/*.mm")
file(GLOB objc_generated_headers "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objc/*.h")
file(GLOB objcpp_generated_src "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objcpp/*.mm")
file(GLOB objcpp_generated_headers "${CMAKE_CURRENT_LIST_DIR}/../generated-src/objcpp/*.h")
file(GLOB cpp_generated_headers "${CMAKE_CURRENT_LIST_DIR}/../generated-src/cpp/*.hpp")

# implementation
file(GLOB cpp_src "${CMAKE_CURRENT_LIST_DIR}/../src/cpp/*.cpp")
file(GLOB cpp_headers "${CMAKE_CURRENT_LIST_DIR}/../src/cpp/*.hpp")
file(GLOB objc_src "${CMAKE_CURRENT_LIST_DIR}/../src/objc/*.m")
file(GLOB objc_headers "${CMAKE_CURRENT_LIST_DIR}/../src/objc/*.h")

# ----------------------------------------------------------------------------------------------------------------------
# Boost - http://www.boost.org
# ----------------------------------------------------------------------------------------------------------------------

#set(BOOST_INCLUDEDIR "${CMAKE_CURRENT_LIST_DIR}/include")
#set(BOOST_LIBRARYDIR "${CMAKE_CURRENT_LIST_DIR}/lib")
#set(BOOST_ROOT "${CMAKE_CURRENT_LIST_DIR}")
#set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_USE_STATIC_LIBS ON)

#message(STATUS "BOOST_INCLUDEDIR = ${BOOST_INCLUDEDIR}")
#message(STATUS "BOOST_LIBRARYDIR = ${BOOST_LIBRARYDIR}")

find_package(Boost 1.66.0 REQUIRED COMPONENTS log log_setup system thread filesystem)

# ----------------------------------------------------------------------------------------------------------------------
# djinni support library
# ----------------------------------------------------------------------------------------------------------------------

find_library(djinni NAMES djinni-support)
if(${djinni} STREQUAL "djinni-NOTFOUND")
    message(FATAL_ERROR "Couldn't find the djinni library. Please check the Readme for required dependencies.")
else()
    message(STATUS "Found 'djinni' at: ${djinni}")
endif()

# ----------------------------------------------------------------------------------------------------------------------
# appcom-djinni-common
# ----------------------------------------------------------------------------------------------------------------------

add_library(appcom-djinni-common
            STATIC
            # generated objective-c++ code
            ${objc_generated_src}
            # generated objective-c code
            ${objcpp_generated_src}
            # implementation
            ${cpp_src}
            ${objc_src}
            )

set_target_properties(appcom-djinni-common PROPERTIES COMPILE_FLAGS "-fobjc-arc")

target_include_directories(appcom-djinni-common PRIVATE
                    # djinni support library
                    ${CMAKE_CURRENT_SOURCE_DIR}/../deps/djinni/support-lib/objc
                    # djinni generated code
                    ../generated-src/cpp
                    ../generated-src/objc
                    ../generated-src/objcpp
                    # implementation
                    ../src/cpp
                    ../src/objc
                    # Boost
                    ${Boost_INCLUDE_DIRS})

target_link_libraries(appcom-djinni-common
                      ${djinni}
                      ${Boost_LIBRARIES})

install(TARGETS appcom-djinni-common
        LIBRARY DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/lib/"
        ARCHIVE DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/lib/")

install(FILES 
        ${objc_generated_headers} 
        ${cpp_headers} 
        ${objc_headers} 
        ${objcpp_generated_headers} 
        ${cpp_generated_headers}
        DESTINATION "${CMAKE_CURRENT_LIST_DIR}/../output/include/appcom/djinni/common")
