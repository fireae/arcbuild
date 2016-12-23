# The MIT License (MIT)
# Copyright © 2016 Naiyang Lin <maxint@foxmail.com>
#
# Supported (environment) variables:
#
# - SDK_ARCH: target architecture
# - SDK_TARGET_TOOLCHAIN_ROOT: custom target toolchain root directory
# - SDK_TARGET_TRIPLE: custom target triple, parse from SDK_USE_CUSTOM_SYSROOT if empty
#

# basic setup
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${SDK_ARCH}) # optional

if(NOT SDK_TARGET_TOOLCHAIN_ROOT)
  if (DEFINED ENV{SDK_TARGET_TOOLCHAIN_ROOT})
    set(SDK_TARGET_TOOLCHAIN_ROOT "$ENV{SDK_TARGET_TOOLCHAIN_ROOT}")
    set(SDK_USE_CUSTOM_SYSROOT 1)
  endif()
endif()
message(STATUS "SDK_TARGET_TOOLCHAIN_ROOT: ${SDK_TARGET_TOOLCHAIN_ROOT}")

if(NOT SDK_TARGET_TRIPLE)
  if(DEFINED ENV{SDK_TARGET_TRIPLE})
    set(SDK_TARGET_TRIPLE $ENV{SDK_TARGET_TRIPLE})
  else()
    get_filename_component(SDK_TARGET_TRIPLE ${SDK_TARGET_TOOLCHAIN_ROOT} NAME)
  endif()
endif()
message(STATUS "SDK_TARGET_TRIPLE: ${SDK_TARGET_TRIPLE}")

# CMAKE_SYSROOT
find_path(CMAKE_SYSROOT
  NAMES include/assert.h
  HINTS ${SDK_TARGET_TOOLCHAIN_ROOT}/sysroot
        ${SDK_TARGET_TOOLCHAIN_ROOT}/libc
        ${SDK_TARGET_TOOLCHAIN_ROOT}
  PATH_SUFFIXES usr
  NO_DEFAULT_PATH
  )
message(STATUS "CMAKE_SYSROOT: ${CMAKE_SYSROOT}")

# C++ include directory
if(NOT SDK_CXX_DIR)
  file(GLOB SDK_CXX_DIR "${SDK_TARGET_TOOLCHAIN_ROOT}/include/c++/*/")
endif()
message(STATUS "SDK_CXX_DIR: ${SDK_CXX_DIR}")

# compilers
find_program(CMAKE_C_COMPILER gcc)
find_program(CMAKE_CXX_COMPILER g++)

# NOTE: fix bug of no -D* passed when checking compilers
include(CMakeForceCompiler)
cmake_force_c_compiler(${CMAKE_C_COMPILER} GNU)
cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} GNU)

# compiler and linker flags
if(NOT SDK_ARCH MATCHES "(x86|x64)")
  set(CMAKE_C_FLAGS "-march=${SDK_ARCH}")
endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -I${SDK_CXX_DIR} -I${SDK_CXX_DIR}/${SDK_TARGET_TRIPLE}" CACHE STRING "C++ Flags" FORCE)
set(CMAKE_LINKER_FLAGS "-lc -lm -lstdc++ -lgcc -ldl -lrt" CACHE STRING "Linker Flags" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)

# NOTE: (optional) do not contribute to find compiler program, e.g. ar
#set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
#set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# vim:ft=cmake et ts=2 sts=2 sw=2:
