# The MIT License (MIT)
# Copyright © 2016 Naiyang Lin <maxint@foxmail.com>
#
# Android NDK toolchain file for CMake
#
# Note: this version targets NDK r8, r9, r10
#
# need to know where the NDK resides, enviroment variable SDK_ROOT
#
#   SDK_API_VERSION - Android API version
#
#     Default: android-9
#     Posible values are independent on NDK version
#
#   SDK_ARCH - architecture
#
#     Default: armv7-a
#     Posible values are:
#       arm
#       armv6
#       armv7-a
#       arm64
#       x86
#       x86_64
#       mips
#       mips64
#
#   SDK_TOOLCHAIN - toolchain name
#
#     Default: lastest gcc toolchain, e.g. arm-linux-androideabi-4.9
#     Posible values are independent on NDK version
#
#   SDK_STL - specify the runtime to use
#
#     Default: system
#     Posible values are:
#       system
#       gabi++
#       gnustl
#       stlport
#

# SDK_ROOT
if(NOT SDK_ROOT)
  if(DEFINED ENV{SDK_ROOT})
    set(SDK_ROOT $ENV{SDK_ROOT})
  endif()
endif()
if(NOT SDK_ROOT)
  message(FATAL_ERROR "Please set SDK_ROOT variable to toolchain root directory")
endif()

# for convenience
set(ANDROID 1)

# SDK_API_VERSION
file(GLOB SDK_API_VERSION_SUPPORTED RELATIVE ${SDK_ROOT}/platforms "${SDK_ROOT}/platforms/android-*")
if(NOT SDK_API_VERSION)
  set(SDK_API_VERSION "android-9")
  list(FIND SDK_API_VERSION_SUPPORTED ${SDK_API_VERSION} SDK_API_FOUND)
  if(SDK_API_FOUND EQUAL -1)
    list(GET SDK_API_VERSION_SUPPORTED -1 SDK_API_LATEST)
    message(WARNING "SDK_API_VERSION (${SDK_API_VERSION}) is not supported (${SDK_API_VERSION_SUPPORTED}). Use the latest one (${SDK_API_LATEST})")
    set(SDK_API_VERSION ${SDK_API_LATEST})
  endif()
endif()
set(SDK_API_ROOT ${SDK_ROOT}/platforms/${SDK_API_VERSION})

# SDK_ARCH
if(NOT SDK_ARCH)
  set(SDK_ARCH "armv7-a")
endif()

# SDK_ABI
set(SDK_ABI ${SDK_ARCH})
if(SDK_ARCH STREQUAL "arm")
  set(SDK_ABI "armeabi")
  set(SDK_PROCESSOR "ARM")
  set(SDK_C_FLAGS "-march=armv5te -mtune=xscale -msoft-float")
  set(SDK_LLVM_TRIPLE "armv5te-none-linux-androideabi")
elseif(SDK_ARCH STREQUAL "armv6")
  set(SDK_ABI "armeabi-v6")
  set(SDK_PROCESSOR "ARM")
  set(SDK_C_FLAGS "-march=armv6 -mfloat-abi=softfp -mfpu=vfp")
  set(SDK_LLVM_TRIPLE "armv6-none-linux-androideabi")
elseif(SDK_ARCH STREQUAL "armv7-a")
  set(SDK_ABI "armeabi-v7a")
  set(SDK_PROCESSOR "ARM")
  set(SDK_C_FLAGS "-march=armv7-a -mfloat-abi=softfp -mfpu=neon -ftree-vectorize -ffast-math")
  set(SDK_LLVM_TRIPLE "armv7-none-linux-androideabi")
elseif(SDK_ARCH STREQUAL "armv8-a")
  set(SDK_ABI "arm64-v8a")
  set(SDK_PROCESSOR "ARM64")
  set(SDK_C_FLAGS "-march=armv8-a")
  set(SDK_LLVM_TRIPLE "aarch64-none-linux-androideabi")
#elseif(SDK_ARCH STREQUAL "x86")
#elseif(SDK_ARCH STREQUAL "x86_64")
#elseif(SDK_ARCH STREQUAL "mips")
#elseif(SDK_ARCH STREQUAL "mips64")
else()
  message(FATAL_ERROR "Unsupported ARCH: ${SDK_ARCH}")
endif()
set(_lib_root "${SDK_ROOT}/sources/cxx-stl/stlport/libs")
file(GLOB SDK_ABI_SUPPORTED RELATIVE "${_lib_root}" "${_lib_root}/*")
list(FIND SDK_ABI_SUPPORTED ${SDK_ABI} SDK_ABI_FOUND)
if(SDK_ABI_FOUND EQUAL -1)
  message(WARNING "SDK_ABI (${SDK_ABI}) is not supported (${SDK_ABI_SUPPORTED}). Rollback to 'armeabi'")
  set(SDK_ABI "armeabi")
endif()
unset(_lib_root)

# system info
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION ${SDK_API_VERSION})
set(CMAKE_SYSTEM_PROCESSOR ${SDK_PROCESSOR})

string(TOLOWER "${SDK_PROCESSOR}" SDK_PROCESSOR)

# sysroot - in Android this in function of Android API and architecture
set(CMAKE_SYSROOT "${SDK_API_ROOT}/arch-${SDK_PROCESSOR}")

# toolchain
if(SDK_PROCESSOR STREQUAL "arm64")
  set(SDK_TOOLCHAIN_PREFIX "aarch64")
elseif(SDK_PROCESSOR STREQUAL "amd64")
  set(SDK_TOOLCHAIN_PREFIX "x86_64")
elseif(SDK_PROCESSOR MATCHES "mips")
  set(SDK_TOOLCHAIN_PREFIX "${SDK_PROCESSOR}el")
else()
  set(SDK_TOOLCHAIN_PREFIX ${SDK_PROCESSOR})
endif()
file(GLOB SDK_TOOLCHAIN_SUPPORTED RELATIVE "${SDK_ROOT}/toolchains" "${SDK_ROOT}/toolchains/${SDK_TOOLCHAIN_PREFIX}-*")
list(SORT SDK_TOOLCHAIN_SUPPORTED)
list(REVERSE SDK_TOOLCHAIN_SUPPORTED)
if(NOT SDK_TOOLCHAIN)
  if(DEFINED ENV{SDK_TOOLCHAIN})
    set(SDK_TOOLCHAIN $ENV{SDK_TOOLCHAIN})
  endif()
endif()
if(NOT SDK_TOOLCHAIN)
  foreach(_TC ${SDK_TOOLCHAIN_SUPPORTED})
    if(NOT _TC MATCHES "(llvm|clang)") # skip the llvm/clang
      set(SDK_TOOLCHAIN ${_TC})
      break()
    endif()
  endforeach()
  message(STATUS "Available toolchains: ${SDK_TOOLCHAIN_SUPPORTED}")
  message(STATUS "No SDK_TOOLCHAIN is set. Use the latest gcc toolchain: ${SDK_TOOLCHAIN}")
endif()
file(GLOB SDK_TOOLCHAIN_ROOT "${SDK_ROOT}/toolchains/${SDK_TOOLCHAIN}/prebuilt/*")

# get arch, ABI and gcc version
string(REGEX MATCH "([.0-9]+)$" SDK_COMPILER_VERSION "${SDK_TOOLCHAIN}")

# STL
set(SDK_STL_SUPPORTED "system;gabi++;gnustl;stlport")
if(NOT SDK_STL)
  if(DEFINED ENV{SDK_STL})
    set(SDK_STL $ENV{SDK_STL})
  endif()
endif()
if(NOT SDK_STL)
  message(STATUS "No SDK_STL is set. Use 'system' STL")
  set(SDK_STL "system")
endif()

set(SDK_STL_ROOT "${SDK_ROOT}/sources/cxx-stl")
if(SDK_STL STREQUAL "system")
  set(SDK_RTTI             OFF)
  set(SDK_EXCEPTIONS       OFF)
  set(SDK_STL_ROOT         "${SDK_STL_ROOT}/system")
  set(SDK_STL_INCLUDE_DIRS "${SDK_STL_ROOT}/include")
elseif(SDK_STL STREQUAL "gabi++")
  set(SDK_RTTI             ON)
  set(SDK_EXCEPTIONS       ON)
  set(SDK_STL_ROOT         "${SDK_STL_ROOT}/gabi++")
  set(SDK_STL_INCLUDE_DIRS "${SDK_STL_ROOT}/include")
  set(SDK_STL_LDFLAGS      "-L${SDK_STL_ROOT}/libs/${SDK_ABI}")
elseif(SDK_STL STREQUAL "stlport")
  set(SDK_RTTI             ON)
  set(SDK_EXCEPTIONS       ON)
  set(SDK_STL_ROOT         "${SDK_STL_ROOT}/stlport")
  set(SDK_STL_INCLUDE_DIRS "${SDK_STL_ROOT}/stlport")
  set(SDK_STL_LDFLAGS      "-L${SDK_STL_ROOT}/libs/${SDK_ABI}")
elseif(SDK_STL STREQUAL "gnustl")
  set(SDK_RTTI             ON)
  set(SDK_EXCEPTIONS       ON)
  set(SDK_STL_ROOT         "${SDK_STL_ROOT}/gnu-libstdc++/${SDK_COMPILER_VERSION}")
  set(SDK_STL_INCLUDE_DIRS "${SDK_STL_ROOT}/include" "${SDK_STL_ROOT}/libs/${SDK_ABI}/include")
  set(SDK_STL_LDFLAGS      "-L${SDK_STL_ROOT}/libs/${SDK_ABI} -lsupc++")
else()
  message(FATAL_ERROR "Unknown NDK STL: ${SDK_STL}")
endif()
# NOTE: set -fno-exceptions -fno-rtti when use system
if(NOT SDK_RTTI)
  set(SDK_CXX_FLAGS "-fno-rtti")
endif()
if(NOT SDK_EXCEPTIONS)
  set(SDK_CXX_FLAGS "${SDK_CXX_FLAGS} -fno-exceptions")
endif()

# search paths
set(CMAKE_FIND_ROOT_PATH "${SDK_TOOLCHAIN_ROOT}/bin" "${CMAKE_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# find clang
file(GLOB SDK_CLANG_TOOLCHAIN_ROOT "${SDK_ROOT}/toolchains/llvm/prebuilt/*")
# NOTE: clang is slower than gcc in ndk-r11b for OT, DISABLE it
unset(SDK_CLANG_TOOLCHAIN_ROOT)
if(SDK_CLANG_TOOLCHAIN_ROOT)
  message(STATUS "Use clang: ${SDK_CLANG_TOOLCHAIN_ROOT}")
endif()

# compilers (set CMAKE_C_COMPILER_ID and CMAKE_CXX_COMPILER automatically)
find_program(CMAKE_C_COMPILER
  NAMES
  clang
  arm-linux-androideabi-gcc aarch64-linux-android-gcc
  mipsel-linux-android-gcc mips64el-linux-android-gcc
  i686-linux-android-gcc x86_64-linux-android-gcc
  PATH_SUFFIXES bin
  PATHS ${SDK_CLANG_TOOLCHAIN_ROOT} ${SDK_TOOLCHAIN_ROOT}
  NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER
  NAMES
  clang++
  arm-linux-androideabi-g++ aarch64-linux-android-g++
  mipsel-linux-android-g++ mips64el-linux-android-g++
  i686-linux-android-g++ x86_64-linux-android-g++
  PATH_SUFFIXES bin
  PATHS ${SDK_CLANG_TOOLCHAIN_ROOT} ${SDK_TOOLCHAIN_ROOT}
  NO_DEFAULT_PATH)
# NOTE: fix bug of no -D* passed when checking compilers
# include(CMakeForceCompiler)
# cmake_force_c_compiler(${CMAKE_C_COMPILER} GNU)
# cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} GNU)

# find path of libgcc.a
find_program(SDK_GCC_COMPILER
  NAMES
  arm-linux-androideabi-gcc aarch64-linux-android-gcc
  mipsel-linux-android-gcc mips64el-linux-android-gcc
  i686-linux-android-gcc x86_64-linux-android-gcc
  PATHS "${SDK_TOOLCHAIN_ROOT}/bin")
execute_process(COMMAND "${SDK_GCC_COMPILER} -print-libgcc-file-name" OUTPUT_VARIABLE SDK_LIBGCC)
#message(STATUS ${SDK_LIBGCC})

# global includes and link directories
include_directories(SYSTEM ${SDK_STL_INCLUDE_DIRS})

# cflags, cppflags, ldflags
# NOTE: -nostdlib causes link error when compiling 'viv': hidden symbol `__dso_handle'
if(SDK_CLANG_TOOLCHAIN_ROOT)
  set(CLANG_C_FLAGS "-target ${SDK_LLVM_TRIPLE} -Qunused-arguments -gcc-toolchain ${SDK_TOOLCHAIN_ROOT}")
else()
  set(CLANG_C_FLAGS)
endif()
set(CMAKE_C_FLAGS "${CLANG_C_FLAGS} -fno-short-enums ${SDK_C_FLAGS}")
# set sysroot manually for low version cmake
#set(CMAKE_C_FLAGS "--sysroot=${CMAKE_SYSROOT} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${SDK_CXX_FLAGS}")
set(CMAKE_LINKER_FLAGS "${SDK_LIBGCC} ${SDK_STL_LDFLAGS} -lc -lm -lstdc++ -ldl -llog")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_LINKER_FLAGS}")

# vim:ft=cmake et ts=2 sts=2 sw=2:
