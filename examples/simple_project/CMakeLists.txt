cmake_minimum_required(VERSION 3.0)

project(simple_project)

## Library
file(GLOB_RECURSE HDRS inc/*.h)
file(GLOB_RECURSE SRCS src/*.cpp src/*.h)
add_library(arcsoft_xxx ${HDRS} ${SRCS})
target_include_directories(arcsoft_xxx PUBLIC inc)

## Sample codes
add_executable(samplecode samplecodes/samplecode.c)
target_link_libraries(samplecode arcsoft_xxx)

## Enable arcbuild functions
find_path(ARCBUILD_ROOT_DIR arcbuild.cmake PATHS
  ${CMAKE_BINARY_DIR}/arcbuild
  ${ARCBUILD_ROOT_DIR}
  ../.. # for example projects
)
# list(APPEND CMAKE_MODULE_PATH
#   ${ARCBUILD_ROOT_DIR}
#   ${ARCBUILD_ROOT_DIR}/plugins
# )

## Enable features
include(${ARCBUILD_ROOT_DIR}/arcbuild.cmake)
arcbuild_enable_features(cxx11 neon sse2 hidden)

## Define ArcSoft SDK
include(${ARCBUILD_ROOT_DIR}/plugins/arcsoft_sdk.cmake)
arcbuild_define_arcsoft_sdk(
  arcsoft_xxx
  LIBRARY arcsoft_xxx
  INCS inc/*.h
  VERSION_FILE src/version.c
  RELEASE_NOTES releasenotes.txt
  DOCS doc/*.pdf
)

# Debug
message(${CMAKE_C_FLAGS})
message(${CMAKE_CXX_FLAGS})
