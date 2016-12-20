# Copyright © 2014 maxint <NOT_SPAM_lnychina@gmail.com>
#
# Distributed under terms of the MIT license.
#
# Supported (environment) variables:
#
# - SDK_ROOT: SDK root directory
#

# get SDK root
if(NOT SDK_ROOT)
  if(DEFINED ENV{SDK_ROOT})
    set(SDK_ROOT $ENV{SDK_ROOT})
  endif()
  set(SDK_ROOT "${SDK_ROOT}" CACHE PATH "Tizen toolchain location")
endif()

# basic setup
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm) # optional

# platform flags
set(TIZEN 1)

# SDK related directories
set(CMAKE_SYSROOT ${SDK_ROOT}/tools/usr/arm-linux-gnueabi)
set(TIZEN_CXX_DIR ${CMAKE_SYSROOT}/include/c++/4.5.3)

# compilers
find_program(CMAKE_C_COMPILER arm-linux-gnueabi-gcc PATHS "${SDK_ROOT}/tools/usr/bin" NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER arm-linux-gnueabi-g++ PATHS "${SDK_ROOT}/tools/usr/bin" NO_DEFAULT_PATH)
find_program(CMAKE_AR ar PATH "${TIZEN_GCC_TOOLCHAIN}/arm-linux-gnueabi/bin" NO_DEFAULT_PATH)
# NOTE: fix bug of no -D* passed when checking compilers
# include(CMakeForceCompiler)
# cmake_force_c_compiler(${CMAKE_C_COMPILER} GNU)
# cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} GNU)

# compiler and linker flags
set(TIZEN_C_FLAGS "-fmessage-length=0 -march=${SDK_ARCH} -mtune=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=soft -mthumb -Wa,-mimplicit-it=thumb -mfloat-abi=softfp -mfpu=neon")
set(CMAKE_C_FLAGS "${TIZEN_C_FLAGS} -I${TIZEN_CXX_DIR} -I${TIZEN_CXX_DIR}/arm-linux-gnueabi" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C++ Flags" FORCE)
set(CMAKE_LINKER_FLAGS "-Wl,--no-undefined -lc -lm -lstdc++ -lgcc -ldl -lrt" CACHE STRING "Linker Flags" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)

# NOTE: (optional) do not contribute to find compiler program, e.g. ar
#set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
#set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# vim:ft=cmake et ts=2 sts=2 sw=2:
