# Copyright © 2014 maxint <NOT_SPAM_lnychina@gmail.com>
#
# Distributed under terms of the MIT license.

# get SDK root
if(NOT SDK_ROOT)
  if(DEFINED ENV{SDK_ROOT})
    set(SDK_ROOT $ENV{SDK_ROOT})
  endif()
  set(SDK_ROOT "${SDK_ROOT}" CACHE PATH "Aldebaran Robotics cross-compiling toolchain location")
endif()
if(NOT SDK_ROOT)
  message(FATAL_ERROR "Please set SDK_ROOT variable to toolchain root directory")
endif()

set(TARGET_ARCH "i686")
set(TARGET_TUPLE "${TARGET_ARCH}-aldebaran-linux-gnu")

# basic setup
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${TARGET_ARCH}) # optional

# SDK related directories
set(CROSS_ROOT "${SDK_ROOT}")
set(CMAKE_SYSROOT "${CROSS_ROOT}/${TARGET_TUPLE}/sysroot")
file(GLOB CXX_DIR "${CROSS_ROOT}/${TARGET_TUPLE}/include/c++/*")

# compilers
#find_program(CMAKE_C_COMPILER gcc)
#find_program(CMAKE_CXX_COMPILER g++)
find_program(CMAKE_C_COMPILER ${TARGET_TUPLE}-gcc PATHS "${CROSS_ROOT}/bin" NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER ${TARGET_TUPLE}-g++ PATHS "${CROSS_ROOT}/bin" NO_DEFAULT_PATH)
find_program(CMAKE_AR ${TARGET_TUPLE}-ar PATH "${CROSS_ROOT}/bin" NO_DEFAULT_PATH)
find_program(CMAKE_RANLIB ${TARGET_TUPLE}-ranlib PATH "${CROSS_ROOT}/bin" NO_DEFAULT_PATH)

# NOTE: fix bug of no -D* passed when checking compilers
include(CMakeForceCompiler)
cmake_force_c_compiler(${CMAKE_C_COMPILER} GNU)
cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} GNU)

# compiler and linker flags
set(CMAKE_C_FLAGS "-pipe -fomit-frame-pointer")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-align-jumps -fno-align-functions")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-align-labels -fno-align-loops")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32 -mtune=atom")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mssse3 -mfpmath=sse")
if(IS_DIRECTORY "${CROSS_ROOT}/include")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${CROSS_ROOT}/include")
endif()
if(IS_DIRECTORY "${CROSS_ROOT}/../boost")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${CROSS_ROOT}/..")
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -I${CXX_DIR} -I${CXX_DIR}/${TARGET_TUPLE}" CACHE STRING "C++ Flags" FORCE)
set(CMAKE_LINKER_FLAGS "-Wl,--no-undefined -lc -lm -ldl -lrt -lpthread" CACHE STRING "Linker Flags" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_LINKER_FLAGS}" CACHE STRING "" FORCE)

# NOTE: (optional) do not contribute to find compiler program, e.g. ar
# search for program in the build host directories, e.g. make
#set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# vim:ft=cmake et ts=2 sts=2 sw=2:
