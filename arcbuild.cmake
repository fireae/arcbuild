set(ARCBUILD_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(ARCBUILD_DIR "${ARCBUILD_ROOT_DIR}/arcbuild")

include("${ARCBUILD_DIR}/core.cmake")

function(arcbuild_set_from_env)
  foreach(name ${ARGN})
    set(env_value "$ENV{${name}}")
    if(env_value)
      set(${name} "${env_value}" PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(arcbuild_set_to_env)
  foreach(name ${ARGN})
    if(${name})
      set(ENV{${name}} "${${name}}")
    endif()
  endforeach()
endfunction()

function(arcbuild_set_from_short_var prefix)
  foreach(name ${ARGN})
    if(${name})
      set(${prefix}_${name} "${${name}}" PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(arcbuild_set_to_short_var prefix)
  foreach(name ${ARGN})
    set(prefix_name "${prefix}_${name}")
    if(prefix_name)
      set(${name} "${${prefix_name}}" PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(arcbuil_add_to_env_path)
  foreach(path ${ARGN})
    file(TO_NATIVE_PATH "${path}" path)
    if(WIN32)
      set(ENV{PATH} "$ENV{PATH};${path}")
    else()
      set(ENV{PATH} "$ENV{PATH}:${path}")
    endif()
  endforeach()
endfunction()

function(arcbuild_get_toolchain var_name platform)
  if(platform STREQUAL "android")
    set(path "android-ndk.cmake")
  elseif(platform MATCHES "^ios")
    set(path "ios-xcode.cmake")
  elseif(platform MATCHES "^tizen2")
    set(path "tizen2.2.cmake")
  elseif(platform MATCHES "^tizen")
    set(path "tizen1.0.cmake")
  endif()
  set(${var_name} ${path} PARENT_SCOPE)
endfunction()

function(arcbuild_get_make_program var_name platform root)
  if(platform STREQUAL "android")
    file(GLOB path "${root}/prebuilt/*/bin/make*")
  elseif(platform MATCHES "^ios")
    set(path "make")
  elseif(platform MATCHES "^tizen")
    file(GLOB path "${root}/tools/*/bin/make*")
  elseif(platform MATCHES "windows")
    file(GLOB path "${root}/bin/nmake.exe")
  endif()
  set(${var_name} ${path} PARENT_SCOPE)
endfunction()

function(arcbuild_main)
  # Read from environment variables
  arcbuild_set_from_env(CMAKE_SOURCE_DIR CMAKE_BINARY_DIR CMAKE_TOOLCHAIN_FILE CMAKE_MAKE_PROGRAM)
  arcbuild_set_from_env(ARCBUILD_TYPE ARCBUILD_PLATFORM ARCBUILD_SDK ARCBUILD_VERSION)
  arcbuild_set_from_env(SDK_ROOT SDK_ARCH)
  arcbuild_set_from_env(MPABSE_ROOT MPABSE_VERSION)

  # Read from cmake variables
  arcbuild_set_from_short_var(ARCBUILD TYPE PLATFORM SDK VERBOSE)
  arcbuild_set_from_short_var(SDK ROOT ARCH)
  arcbuild_set_from_short_var(CMAKE SOURCE_DIR BINARY_DIR TOOLCHAIN_FILE MAKE_PROGRAM)

  # Write to short variables
  arcbuild_set_to_short_var(ARCBUILD TYPE PLATFORM SDK VERBOSE)
  arcbuild_set_to_short_var(SDK ROOT ARCH)
  arcbuild_set_to_short_var(CMAKE SOURCE_DIR BUILD_DIR TOOLCHAIN_FILE MAKE_PROGRAM)

  # Get toolchain file
  if(NOT TOOLCHAIN_FILE)
    arcbuild_get_toolchain(TOOLCHAIN_FILE ${PLATFORM})
    if(TOOLCHAIN_FILE)
      set(TOOLCHAIN_FILE "${ARCBUILD_ROOT_DIR}/toolchains/${TOOLCHAIN_FILE}")
    endif()
  endif()

  # Get make program
  arcbuild_get_make_program(MAKE_PROGRAM ${PLATFORM} ${ROOT})
  if(MAKE_PROGRAM MATCHES "nmake")
    set(CMAKE_GENERATOR "NMake Makefiles")
  else()
    set(CMAKE_GENERATOR "Unix Makefiles")
  endif()

  # Get binary direcotry
  if(NOT BINARY_DIR)
    set(BINARY_DIR "_arcbuild")
  endif()
  set(BINARY_DIR "${BINARY_DIR}/${SDK_ARCH}")
  string(REPLACE ";" "_" BINARY_DIR "${BINARY_DIR}")

  # Print information
  foreach(name TYPE PLATFORM ARCH SDK ROOT SOURCE_DIR BINARY_DIR TOOLCHAIN_FILE MAKE_PROGRAM CMAKE_GENERATOR)
    arcbuild_echo("- ${name}: ${${name}}")
  endforeach()

  get_filename_component(SOURCE_DIR "${SOURCE_DIR}" ABSOLUTE)
  get_filename_component(BINARY_DIR "${BINARY_DIR}" ABSOLUTE)

  if(NOT IS_DIRECTORY "${BINARY_DIR}")
    file(MAKE_DIRECTORY "${BINARY_DIR}")
  endif()
  execute_process(COMMAND
    cmake
    "${SOURCE_DIR}"
    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
    -G${CMAKE_GENERATOR}
    -DARCBUILD_ROOT_DIR=${ARCBUILD_ROOT_DIR}
    -DARCBUILD_VERBOSE=${VERBOSE}
    -DARCBUILD_TYPE=${ARCBUILD_TYPE}
    -DARCBUILD=1
    -DSDK_ROOT=${SDK_ROOT}
    -DSDK_ARCH=${SDK_ARCH}
    -DCMAKE_MAKE_PROGRAM=${MAKE_PROGRAM}
    WORKING_DIRECTORY "${BINARY_DIR}"
  )
  execute_process(COMMAND
    "${MAKE_PROGRAM}" package
    WORKING_DIRECTORY "${BINARY_DIR}"
  )
endfunction()

if(_BUILD)
  unset(_BUILD)
  arcbuild_main()
endif()
