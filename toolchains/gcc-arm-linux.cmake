# The MIT License (MIT)
# Copyright © 2016 Naiyang Lin <maxint@foxmail.com>
#
# Supported (environment) variables:
#
# - SDK_ROOT: SDK root directory
# - SDK_ARCH: target architecture
# - SDK_TARGET_TOOLCHAIN_ROOT: custom target toolchain root directory
#

# get SDK root
if(NOT SDK_ROOT)
  if(DEFINED ENV{SDK_ROOT})
    set(SDK_ROOT "$ENV{SDK_ROOT}")
  endif()
  set(SDK_ROOT "${SDK_ROOT}" CACHE PATH "SDK toolchain location")
endif()
if(NOT SDK_ROOT)
  message(FATAL_ERROR "Please set SDK_ROOT variable to toolchain root directory")
else()
  message(STATUS "SDK_ROOT: ${SDK_ROOT}")
endif()

# basic setup
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ARM) # optional

set(TARGET_TOOLCHAIN arm-linux-gnueabi)

if(NOT SDK_TARGET_TOOLCHAIN_ROOT)
  if (DEFINED ENV{SDK_TARGET_TOOLCHAIN_ROOT})
    set(SDK_TARGET_TOOLCHAIN_ROOT "$ENV{SDK_TARGET_TOOLCHAIN_ROOT}")
    set(SDK_USE_CUSTOM_SYSROOT 1)
  else()
    set(SDK_TARGET_TOOLCHAIN_ROOT "${SDK_ROOT}/${TARGET_TOOLCHAIN}")
  endif()
endif()
message(STATUS "SDK_TARGET_TOOLCHAIN_ROOT: ${SDK_TARGET_TOOLCHAIN_ROOT}")

# CMAKE_SYSROOT
find_path(CMAKE_SYSROOT
  NAMES usr/include/assert.h
  HINTS ${SDK_TARGET_TOOLCHAIN_ROOT}/sysroot
        ${SDK_TARGET_TOOLCHAIN_ROOT}/libc
  NO_DEFAULT_PATH
  )
message(STATUS "CMAKE_SYSROOT: ${CMAKE_SYSROOT}")

# C++ include directory
if(NOT SDK_CXX_DIR)
  file(GLOB SDK_CXX_DIR "${SDK_TARGET_TOOLCHAIN_ROOT}/include/c++/*/")
endif()
message(STATUS "SDK_CXX_DIR: ${SDK_CXX_DIR}")

# compilers
find_program(CMAKE_C_COMPILER ${TARGET_TOOLCHAIN}-gcc PATHS "${SDK_ROOT}/bin" NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER ${TARGET_TOOLCHAIN}-g++ PATHS "${SDK_ROOT}/bin" NO_DEFAULT_PATH)
find_program(CMAKE_AR ${TARGET_TOOLCHAIN}-ar PATH "${SDK_ROOT}/bin" NO_DEFAULT_PATH)
find_program(CMAKE_RANLIB ${TARGET_TOOLCHAIN}-ranlib PATH "${SDK_ROOT}/bin" NO_DEFAULT_PATH)

# NOTE: fix bug of no -D* passed when checking compilers
# include(CMakeForceCompiler)
# cmake_force_c_compiler(${CMAKE_C_COMPILER} GNU)
# cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} GNU)

# compiler and linker flags
set(CMAKE_C_FLAGS "-march=${SDK_ARCH}" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -I${SDK_CXX_DIR} -I${SDK_CXX_DIR}/${TARGET_TOOLCHAIN}" CACHE STRING "C++ Flags" FORCE)
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
