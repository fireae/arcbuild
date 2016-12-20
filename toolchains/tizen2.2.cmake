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
set(CMAKE_SYSROOT ${SDK_ROOT}/platforms/tizen2.2/rootstraps/tizen-device-2.2.native)
set(TIZEN_CXX_DIR ${CMAKE_SYSROOT}/usr/include/c++/4.5.3)
set(TIZEN_GCC_TOOLCHAIN ${SDK_ROOT}/tools/arm-linux-gnueabi-gcc-4.5)

# compilers
find_program(CMAKE_C_COMPILER clang PATHS "${SDK_ROOT}/tools/llvm-3.1/bin" NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER clang++ PATHS "${SDK_ROOT}/tools/llvm-3.1/bin" NO_DEFAULT_PATH)
find_program(CMAKE_AR ar PATH "${TIZEN_GCC_TOOLCHAIN}/arm-linux-gnueabi/bin" NO_DEFAULT_PATH)
# NOTE: fix bug of no -D* passed when checking compilers
# include(CMakeForceCompiler)
# cmake_force_c_compiler(${CMAKE_C_COMPILER} Clang)
# cmake_force_cxx_compiler(${CMAKE_CXX_COMPILER} Clang)

# compiler and linker flags
set(TIZEN_C_FLAGS "-fmessage-length=0 -march=${SDK_ARCH} -mtune=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=soft -mthumb -Wa,-mimplicit-it=thumb -fpic -mfloat-abi=softfp -mfpu=neon")
set(CMAKE_C_FLAGS "${TIZEN_C_FLAGS} -target arm-tizen-linux-gnueabi -gcc-toolchain ${TIZEN_GCC_TOOLCHAIN} -I${TIZEN_CXX_DIR} -I${TIZEN_CXX_DIR}/armv7l-tizen-linux-gnueabi" CACHE STRING "C Flags" FORCE)
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
