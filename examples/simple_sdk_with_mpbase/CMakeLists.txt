cmake_minimum_required(VERSION 2.8.12)

project(SIMPLE_SDK_WITH_MPBASE)

if(NOT ARCBUILD_TYPE)
  set(ARCBUILD_TYPE SHARED)
endif()

## Library
file(GLOB_RECURSE HDRS inc/*.h)
file(GLOB_RECURSE SRCS src/*.h src/*.c src/*.cpp)
add_library(arcsoft_xxx ${ARCBUILD_TYPE} ${HDRS} ${SRCS})
target_include_directories(arcsoft_xxx PUBLIC inc)

## Sample codes
add_executable(samplecode samplecodes/samplecode.c)
target_link_libraries(samplecode arcsoft_xxx)

# Enable arcbuild functions
include(../../arcbuild.cmake)
arcbuild_enable_features(cxx11 neon sse2 hidden)

# Add mpbase
include(${ARCBUILD_DIR}/mpbase.cmake)
target_link_libraries(arcsoft_xxx mpbase)

# Define ArcSoft SDK
if(ARCBUILD)
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
