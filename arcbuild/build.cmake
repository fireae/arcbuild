include("${ARCBUILD_DIR}/core.cmake")

function(arcbuild_set_from_env)
  foreach(name ${ARGN})
    if(DEFINED ENV{${name}})
      set(${name} "${ENV{${name}}}" PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(arcbuild_add_env)
  foreach(name ${ARGN})
    if(${name})
      set(ENV{${name}} "${${name}}")
      list(APPEND appended_items ${name})
    endif()
  endforeach()
  set(ARCBUILD_ENV_VARIABLES ${ARCBUILD_ENV_VARIABLES} ${appended_items} PARENT_SCOPE)
endfunction()

function(arcbuild_clean_env)
  foreach(name ${ARCBUILD_ENV_VARIABLES})
    unset(ENV{${name}})
  endforeach()
  unset(ARCBUILD_ENV_VARIABLES PARENT_SCOPE)
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
    if(${prefix_name})
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
  if(path)
    set(${var_name} ${path} PARENT_SCOPE)
  endif()
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
  get_filename_component(path "${path}" ABSOLUTE)
  set(${var_name} ${path} PARENT_SCOPE)
endfunction()

function(arcbuild_get_vc_root var_name sdk)
  if(sdk STREQUAL "vs2012")
    set(version 11)
  elseif(sdk STREQUAL "vs2013")
    set(version 12)
  elseif(sdk STREQUAL "vs2015")
    set(version 14)
  endif()
  find_path(path NAMES "vcvarsall.bat" PATHS
    "$ENV{VS${version}0COMNTOOLS}/../../VC"
    "$ENV{ProgramFiles}/Microsoft Visual Studio ${version}.0/VC"
    "$ENV{ProgramFiles} (x86)/Microsoft Visual Studio ${version}.0/VC"
    NO_DEFAULT_PATH
  )
  if(path)
    get_filename_component(path "${path}" ABSOLUTE)
    file(TO_NATIVE_PATH "${path}" path)
    set(${var_name} ${path} PARENT_SCOPE)
    unset(path CACHE)
  else()
    arcbuild_error("Unknown VC SDK: ${sdk}")
  endif()
endfunction()

function(arcbuild_get_vc_env_run var_name root arch)
  if(DEFINED ENV{ProgramW6432})
    if(arch STREQUAL "arm")
      set(arch "amd64_arm")
    elseif(arch STREQUAL "x64")
      set(arch "amd64")
    elseif(arch STREQUAL "x86")
      set(arch "amd64_x86")
    endif()
  else()
    if(arch STREQUAL "arm")
      set(arch "x86_arm")
    elseif(arch STREQUAL "x64")
      set(arch "x86_amd64")
    elseif(arch STREQUAL "x86")
      set(arch "x86")
    endif()
  endif()
  if(arch)
    find_path(path NAMES "bin/${arch}/cl.exe" PATHS ${root} NO_DEFAULT_PATH)
  endif()
  if(path)
    set(cmd "${root}\\vcvarsall.bat" ${arch})
    set(${var_name} ${cmd} PARENT_SCOPE)
    unset(path CACHE)
  else()
    arcbuild_error("Unsupported arch(${arch}) in VC (${root})")
  endif()
endfunction()


function(arcbuild_build)
  ##############################
  # Parse arguments

  # Read from environment variables
  # arcbuild_set_from_env(ARCBUILD_TYPE ARCBUILD_PLATFORM ARCBUILD_SDK ARCBUILD_VERSION ARCBUILD_SUFFIX)
  # arcbuild_set_from_env(SDK_ROOT SDK_ARCH SDK_API_VERSION)
  # arcbuild_set_from_env(MPABSE_DIR MPABSE_ROOT MPABSE_VERSION)

  # Write to short variables
  # arcbuild_set_to_short_var(ARCBUILD TYPE PLATFORM SDK VERBOSE)
  # arcbuild_set_to_short_var(SDK ROOT ARCH API_VERSION STL)

  # Verbose
  if(NOT VERBOSE)
    set(VERBOSE 1)
  endif()
  if(VERBOSE GREATER 1)
    set(VERBOSE_MAKEFILE 1)
  endif()
  arcbuild_set_from_short_var(ARCBUILD VERBOSE)

  arcbuild_echo("--------------------------")
  arcbuild_echo("--*-- START building --*--")

  ##############################
  # Default values
  if(NOT PLATFORM)
    arcbuild_error("Please set target platform, e.g. -DPLATFORM=android")
  endif()

  # PLATFORM & SDK for vc
  if(PLATFORM MATCHES "^(vc|vs)[0-9]+")
    set(SDK ${PLATFORM})
    set(PLATFORM "windows")
  endif()

  # ARCH
  if(NOT ARCH)
    if(PLATFORM MATCHES "^(windows|linux|mac)$")
      set(ARCH "x86")
    elseif(PLATFORM MATCHES "^(android|tizen)$")
      set(ARCH "armv7-a")
    elseif(PLATFORM MATCHES "^ios")
      set(ARCH "armv7;armv7s;arm64")
    endif()
  endif()

  # BUILD_TYPE
  if(NOT BUILD_TYPE)
    set(BUILD_TYPE "Release")
  endif()

  # VC ROOT
  if(PLATFORM STREQUAL "windows" AND NOT ROOT)
    arcbuild_get_vc_root(ROOT "${SDK}")
    arcbuild_get_vc_env_run(VC_ENV_RUN "${ROOT}" "${ARCH}")
  endif()

  # API_VERSION
  if(PLATFORM STREQUAL "android" AND NOT API_VERSION)
    if(ARCH STREQUAL "arm64")
      set(API_VERSION "android-21")
    else()
      set(API_VERSION "android-9")
    endif()
  endif()

  # SOURCE_DIR
  if(NOT SOURCE_DIR)
    get_filename_component(SOURCE_DIR "." ABSOLUTE)
  endif()

  # BINARY_DIR
  if(NOT BINARY_DIR)
    set(BINARY_DIR "_build")
  endif()

  # Get toolchain file
  if(NOT TOOLCHAIN_FILE)
    arcbuild_get_toolchain(TOOLCHAIN_FILE ${PLATFORM})
    if(TOOLCHAIN_FILE)
      set(TOOLCHAIN_FILE "${ARCBUILD_ROOT_DIR}/toolchains/${TOOLCHAIN_FILE}")
    endif()
  endif()

  # Get make program
  arcbuild_get_make_program(MAKE_PROGRAM ${PLATFORM} "${ROOT}")
  if(MAKE_PROGRAM MATCHES "nmake")
    unset(ROOT) # USELESS for vc
    set(CMAKE_GENERATOR "NMake Makefiles")
  else()
    set(CMAKE_GENERATOR "Unix Makefiles")
  endif()

  # Get binary direcotry
  join(binary_subdir "_" ${PLATFORM} ${SDK} ${ARCH})
  set(BINARY_DIR "${BINARY_DIR}/${binary_subdir}")

  ##############################
  # Print information
  arcbuild_echo("Building information:")
  foreach(name PLATFORM SDK SOURCE_DIR BINARY_DIR CMAKE_GENERATOR VC_ENV_RUN)
    if(${name})
      arcbuild_echo("- ${name}: ${${name}}")
    endif()
  endforeach()

  # Set from short variables
  arcbuild_set_from_short_var(ARCBUILD TYPE PLATFORM SDK VERBOSE SUFFIX)
  arcbuild_set_from_short_var(SDK ROOT ARCH API_VERSION STL)
  arcbuild_set_from_short_var(CMAKE TOOLCHAIN_FILE MAKE_PROGRAM VERBOSE_MAKEFILE C_FLAGS CXX_FLAGS BUILD_TYPE)

  # Set environment variables for toolchains
  arcbuild_add_env(SDK_ROOT SDK_ARCH SDK_API_VERSION SDK_STL)

  if(LINK_FLAGS)
    arcbuild_append_link_flags(${LINK_FLAGS})
  endif()
  if(NOT PLATFORM STREQUAL "windows" AND ARCH MATCHES "^(x86|x64)$")
    if(ARCH STREQUAL "x86")
      arcbuild_append_c_flags("-m32")
    elseif(ARCH STREQUAL "x64")
      arcbuild_append_c_flags("-m64")
    endif()
  endif()
  set(cmake_args)
  foreach(name
    ARCBUILD_VERBOSE
    ARCBUILD_TYPE
    ARCBUILD_SUFFIX

    SDK_ROOT
    SDK_ARCH
    SDK_API_VERSION
    SDK_STL

    CMAKE_BUILD_TYPE
    CMAKE_C_FLAGS
    CMAKE_CXX_FLAGS
    CMAKE_SHARED_LINKER_FLAGS
    CMAKE_EXE_LINKER_FLAGS

    CMAKE_TOOLCHAIN_FILE
    CMAKE_MAKE_PROGRAM
    CMAKE_VERBOSE_MAKEFILE

    MPBASE_DIR
    MPBASE_ROOT
    MPBASE_VERSION
    )
    if(${name})
      string(FIND ${name} "_" underline_pos)
      math(EXPR underline_pos "${underline_pos}+1")
      string(SUBSTRING ${name} ${underline_pos} -1 short_name)
      # string(REGEX REPLACE "^[A-Z]+_" "" short_name "${name}")
      arcbuild_echo("- ${short_name}: ${${name}}")
      list(APPEND cmake_args "-D${name}=${${name}}")
    endif()
  endforeach()

  ##############################
  # Build and pack

  get_filename_component(SOURCE_DIR "${SOURCE_DIR}" ABSOLUTE)
  get_filename_component(BINARY_DIR "${BINARY_DIR}" ABSOLUTE)
  if(NOT IS_DIRECTORY "${BINARY_DIR}")
    file(MAKE_DIRECTORY "${BINARY_DIR}")
  endif()

  # Remove old SDK's
  file(GLOB zips "${BINARY_DIR}/*.zip")
  if(zips)
    arcbuild_warn("Removing: ${zips}")
    file(REMOVE "${zips}")
  endif()

  # Build & pack
  set(CMAKE_CMD cmake)
  set(MAKE_CMD ${MAKE_PROGRAM})
  if(VC_ENV_RUN)
    list(GET VC_ENV_RUN 0 VCVARS_BAT)
    list(GET VC_ENV_RUN 1 VC_ARCH)
    list(INSERT CMAKE_CMD 0 ${VC_ENV_RUN} &&)
    list(INSERT MAKE_CMD 0 ${VC_ENV_RUN} &&)
  endif()
  arcbuild_echo("Generating Makefiles ...")
  execute_process(
    COMMAND ${CMAKE_CMD}
    "${SOURCE_DIR}"
    -G${CMAKE_GENERATOR}
    -DARCBUILD=1
    ${cmake_args}
    WORKING_DIRECTORY "${BINARY_DIR}"
  )
  arcbuild_echo("Making SDK ...")
  execute_process(
    COMMAND ${MAKE_CMD} package
    WORKING_DIRECTORY "${BINARY_DIR}"
  )
  arcbuild_clean_env()

  # Copy SDK's to current work directory
  file(GLOB zips "${BINARY_DIR}/*.zip")
  if(zips)
    get_filename_component(current_directory "." ABSOLUTE)
    arcbuild_echo("Copy SDK's to ${current_directory}")
    foreach(zip ${zips})
      arcbuild_echo("- ${zip}")
      execute_process(COMMAND cmake -E copy "${zip}" "${current_directory}")
    endforeach()
  endif()

  arcbuild_echo("--*-- END building --*--")
endfunction()
