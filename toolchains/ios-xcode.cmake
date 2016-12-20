# Copyright (C) 2014 maxint <NOT_SPAM_lnychina@gmail.com>
#
# Distributed under terms of the MIT license.
#
# Options:
#
# SDK_ROOT = automatic (default:xcode-select --print-path) or /path/to/Content/Developer
#   $ xcode-select --print-path
#
# SDK_ARCH = empty (default:armv7;armv7s) or armv6;armv7;armv7s;arm64
#   set the architecture for iOS - sets armv6;armv7;armv7s;arm64 and appears to be XCode's standard.
#
# SDK_API_VERSION = empty (default:oldest) or 6.1|7.1|8.1
#

# cross compiling setup
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR arm) # optional

# platform flags
set(APPLE 1)
set(IOS 1)

# hard set values
if(NOT IOS_TARGET)
  set(IOS_TARGET "iPhoneOS")
endif()
if(NOT SDK_ARCH)
  set(SDK_ARCH "armv7;armv7s")
endif()

# select xcode version and set SDK_ROOT
if((NOT SDK_ROOT) AND (DEFINED ENV{SDK_ROOT}))
  set(SDK_ROOT $ENV{SDK_ROOT})
endif()
if(NOT SDK_ROOT)
  find_program(CMAKE_XCODE_SELECT xcode-select)
  if(CMAKE_XCODE_SELECT)
    execute_process(COMMAND ${CMAKE_XCODE_SELECT} "-print-path"
      OUTPUT_VARIABLE SDK_ROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()
  set(SDK_ROOT "${SDK_ROOT}" CACHE PATH "OSX Developer toolchain location")
endif()
if(NOT SDK_ROOT)
  message(FATAL_ERROR "Please set SDK_ROOT variable to toolchain root directory")
endif()

# some internal values
set(IOS_DEVELOPER_ROOT "${SDK_ROOT}/Platforms/${IOS_TARGET}.platform/Developer")
set(OSX_TOOLCHAIN_ROOT "${SDK_ROOT}/Toolchains/XcodeDefault.xctoolchain")

# Target specific architectures for OS X.
set(CMAKE_OSX_ARCHITECTURES "${SDK_ARCH}" CACHE STRING "Build architectures for iOS")

# Specify the location or name of the OS X platform SDK to be used.
if(NOT CMAKE_OSX_SYSROOT)
  if(NOT SDK_API_VERSION)
    file(GLOB SDK_API_VERSION_SUPPORTED "${IOS_DEVELOPER_ROOT}/SDKs/*")
    list(SORT SDK_API_VERSION_SUPPORTED)
    # has compile error when using the oldest one (0)
    # clang: error: invalid version number in '-miphoneos-version-min=.sd'
    list(GET SDK_API_VERSION_SUPPORTED -1 CMAKE_OSX_SYSROOT)
  else()
    set(CMAKE_OSX_SYSROOT "${IOS_DEVELOPER_ROOT}/SDKs/iPhoneOS${SDK_API_VERSION}.sdk")
  endif()
  message(STATUS "CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT}")
endif()
set(CMAKE_OSX_SYSROOT "${CMAKE_OSX_SYSROOT}" CACHE PATH "Sysroot used for iOS support")
# Specify the minimum version of OS X on which the target binaries are to be deployed.
# CMAKE_OSX_DEPLOYMENT_TARGET # get from CMAKE_OSX_SYSROOT

# root path
set(CMAKE_FIND_ROOT_PATH ${OSX_TOOLCHAIN_ROOT} ${IOS_DEVELOPER_ROOT} ${CMAKE_OSX_SYSROOT})
# search paths (for makefiles the first one might be switched to "NEVER")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# compiler
set(CMAKE_C_COMPILER   ${OSX_TOOLCHAIN_ROOT}/usr/bin/clang)
set(CMAKE_CXX_COMPILER ${OSX_TOOLCHAIN_ROOT}/usr/bin/clang++)
# include(CMakeForceCompiler)
# cmake_force_c_compiler(${CMAKE_C_COMPILER} Clang)
# cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} Clang)

# default to searching for frameworks first
set (CMAKE_FIND_FRAMEWORK FIRST)

# set up the default search directories for frameworks
set (CMAKE_SYSTEM_FRAMEWORK_PATH
  ${IOS_DEVELOPER_ROOT}/System/Library/Frameworks
  ${IOS_DEVELOPER_ROOT}/System/Library/PrivateFrameworks
  ${IOS_DEVELOPER_ROOT}/Developer/Library/Frameworks
)

# set compiler flags
# -v to print version
set(CMAKE_C_FLAGS "" CACHE STRING "C flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C++ flags" FORCE)

# vim:ft=cmake et ts=2 sts=2 sw=2:
