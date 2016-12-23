# The MIT License (MIT)
# Copyright © 2016 Naiyang Lin <maxint@foxmail.com>
#
# Find the given version gcc/g++ in PATH
#
# Supported (environment) variables:
#
# - GCC_VERSION: gcc version
#

# basic setup
set(CMAKE_SYSTEM_NAME Linux)

if(NOT GCC_VERSION AND DEFINED ENV{GCC_VERSION})
  set(GCC_VERSION $ENV{GCC_VERSION})
endif()
if(NOT GCC_VERSION)
  message(FATAL_ERROR "Please set GCC_VERSION variable, e.g. 4.9")
endif()

# compilers
find_program(CMAKE_C_COMPILER gcc-${GCC_VERSION})
find_program(CMAKE_CXX_COMPILER g++-${GCC_VERSION})

