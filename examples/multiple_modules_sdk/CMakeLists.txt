cmake_minimum_required(VERSION 2.8.12)

project(MULTIPLE_MODULES_SDK)

## Modules
add_subdirectory(modules)

## Library
file(GLOB_RECURSE HDRS inc/*.h)
file(GLOB_RECURSE SRCS src/*.h src/*.c src/*.cpp)
add_library(arcsoft_xxx ${ARCBUILD_TYPE} ${HDRS} ${SRCS})
target_include_directories(arcsoft_xxx PUBLIC inc)
target_link_libraries(arcsoft_xxx bar)

## Sample codes
add_executable(samplecode samplecodes/samplecode.c)
target_link_libraries(samplecode arcsoft_xxx)

# Enable arcbuild functions
include(../../arcbuild.cmake)
arcbuild_enable_features(cxx11 neon sse2 hidden)

if(ARCBUILD)
  # Define ArcSoft SDK
  include(${ARCBUILD_DIR}/arcsoft_sdk.cmake)
  arcbuild_define_arcsoft_sdk(
    arcsoft_xxx
    LIBRARY arcsoft_xxx
    INCS inc/*.h
    VERSION_FILE src/version.c
    SAMPLE_CODE samplecode
    RELEASE_NOTES releasenotes.txt
    DOCS doc/*.pdf
  )
endif()
