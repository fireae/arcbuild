include(CMakeParseArguments)

option(ARCBUILD_VERBOSE ${ARCBUILD_VERBOSE} "Verbose output of arcbuild")

function(arcbuild_echo)
  if(ARCBUILD_VERBOSE)
    message(STATUS "ARCBUILD [I] ${ARGN}")
  endif()
endfunction()

function(arcbuild_warn)
  message(STATUS "ARCBUILD [W] " ${ARGN})
endfunction()

function(arcbuild_error)
  message(FATAL_ERROR "ARCBUILD [E] " ${ARGN})
endfunction()

macro(arcbuild_append_c_flags)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ARGN}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARGN}")
endmacro()

macro(arcbuild_append_cxx_flags)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARGN}")
endmacro()

macro(arcbuild_append_link_flags)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${ARGN}")
  set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    ${ARGN}")
endmacro()

macro(arcbuild_enable_cxx11)
  if(MSVC)
    if(MSVC_VERSION VERSION_LESS 1700)
      arcbuild_warn("No C++11 is supported before VS2012")
    endif()
  elseif(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_C_COMPILER_VERSION VERSION_LESS "4.7")
    arcbuild_append_cxx_flags("-std=gnu++11")
  else()
    arcbuild_append_cxx_flags("-std=c++11")
  endif()
endmacro()

macro(arcbuild_enable_neon)
  if(SDK_ARCH MATCHES "armv7")
    arcbuild_append_c_flags("-mfloat-abi=softfp -mfpu=neon -ftree-vectorize -ffast-math")
  else()
    arcbuild_warn("Disable neon")
  endif()
endmacro()

macro(arcbuild_enable_sse)
  if(MSVC)
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      if(NOT ARGN)
        arcbuild_append_c_flags("/arch:SSE")
      elseif(ARGN MATCHES "(2|3|4)")
        arcbuild_append_c_flags("/arch:SSE2")
      else()
        arcbuild_error("Unknown SSE version: ${ARGN}")
      endif()
    endif()
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "(X86|ARM64|X64)")
    if(NOT ARGN)
      arcbuild_append_c_flags("-msse")
    elseif(ARGN LESS 4)
      arcbuild_append_c_flags("-msse${ARGN}")
    elseif(ARGN EQUAL 4)
      arcbuild_append_c_flags("-msse4 -msse4.1 -msse4.2")
    else()
      arcbuild_error("Unknown SSE version: ${ARGN}")
    endif()
  else()
    arcbuild_warn("Disable sse${ARGN}")
  endif()
endmacro()

macro(arcbuild_enable_hidden)
  if(CMAKE_COMPILER_IS_GNUC)
    arcbuild_append_c_flags("-fvisibility=hidden -fdata-sections -ffunction-sections")
    arcbuild_append_cxx_flags("-fvisibility-inlines-hidden")
    arcbuild_append_link_flags("-Wl,--gc-sections -Wl,--as-needed -Wl,--strip-all")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
    arcbuild_append_c_flags("-fvisibility=hidden -fdata-sections -ffunction-sections")
    arcbuild_append_cxx_flags("-fvisibility-inlines-hidden")
    arcbuild_append_link_flags("-Wl,-dead_strip")
  endif()
endmacro()

macro(arcbuild_add_link_flags_undefined)
  if(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND NOT CMAKE_SHARED_LINKER_FLAGS MATCHES "-fembed-bitcode")
    arcbuild_append_link_flags("-Wl,-undefined,error")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    arcbuild_append_link_flags("-Wl,--no-undefined")
  endif()
endmacro()

# use response file to avoid command line length limits
macro(arcbuild_use_response_file lang)
  set(CMAKE_${lang}_USE_RESPONSE_FILE_FOR_OBJECTS 1)
  set(CMAKE_${lang}_USE_RESPONSE_FILE_FOR_INCLUDES 1)
  if(CMAKE_CXX_COMPILER_ID MATCHES "(GNU|Clang)")
    set(CMAKE_${lang}_RESPONSE_FILE_LINK_FLAG "-Wl,@")
  else()
    set(CMAKE_${lang}_RESPONSE_FILE_LINK_FLAG "@")
  endif()
  unset(lang)
endmacro()

macro(arcbuild_enable_features)
  # message(${ARGN})
  # message(${CMAKE_C_COMPILER_VERSION})
  # message(${CMAKE_CXX_COMPILER_VERSION})
  set(features ${ARGN})
  list(REMOVE_DUPLICATES features)
  foreach(feat ${features})
    arcbuild_echo("Try enable feature: ${feat}")
    if(feat STREQUAL "cxx11")
      arcbuild_enable_cxx11()
    elseif(feat STREQUAL "neon")
      arcbuild_enable_neon()
    elseif(feat STREQUAL "sse")
      arcbuild_enable_sse()
    elseif(feat STREQUAL "sse2")
      arcbuild_enable_sse(2)
    elseif(feat STREQUAL "sse3")
      arcbuild_enable_sse(3)
    elseif(feat STREQUAL "sse4")
      arcbuild_enable_sse(4)
    elseif(feat STREQUAL "hidden")
      arcbuild_enable_hidden()
    endif()
  endforeach()
  unset(features)
  unset(feat)

  arcbuild_add_link_flags_undefined()
  arcbuild_use_response_file(C)
  arcbuild_use_response_file(CXX)

  # http://stackoverflow.com/questions/1344830/possible-to-build-a-shared-library-with-static-link-used-library
  # (-fPIC)
  if(CMAKE_CXX_COMPILER_ID MATCHES "(GNU|Clang)")
    set(CMAKE_C_FLAGS "-fPIC ${CMAKE_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "-fPIC ${CMAKE_CXX_FLAGS}")
  endif()
endmacro()

function(arcbuild_collect_link_libraries var_name name)
  get_target_property(all_depends ${name} LINK_LIBRARIES)
  foreach(target ${all_depends})
    if(NOT TARGET ${target})
      continue()
    endif()
    arcbuild_collect_link_libraries(depends ${target})
    list(APPEND all_depends ${depends})
  endforeach()
  if(all_depends)
    set(${var_name} ${all_depends} PARENT_SCOPE)
  endif()
endfunction()

function(join var_name sep)
  string(REGEX REPLACE "([^\\]|^);" "\\1${sep}" result "${ARGN}")
  string(REGEX REPLACE "[\\](.)" "\\1" result "${result}") #fixes escaping
  set(${var_name} "${result}" PARENT_SCOPE)
endfunction()

# Combine all dependencies into one target for SDK delivery
function(arcbuild_combine_target name)
  arcbuild_collect_link_libraries(all_depends ${name})
  if(NOT all_depends)
    return()
  endif()

  list(REMOVE_DUPLICATES all_depends)
  arcbuild_echo("Scaning dependencies for ${name} ...")
  get_target_property(all_sources ${name} SOURCES)
  get_target_property(all_incs ${name} INCLUDE_DIRECTORIES)
  foreach(target ${all_depends})
    arcbuild_echo("- ${target}")
    if(NOT TARGET "${target}")
      continue()
    endif()

    get_target_property(is_imported ${target} IMPORTED)
    get_target_property(sources ${target} SOURCES)
    get_target_property(incs ${target} INCLUDE_DIRECTORIES)
    get_target_property(interface_incs ${target} INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(imported_lib ${target} IMPORTED_IMPLIB)
    if(sources)
      list(APPEND all_sources ${sources})
    endif()
    if(incs)
      list(APPEND all_incs ${incs})
    endif()
    if(interface_incs)
      list(APPEND all_incs ${interface_incs})
    endif()
    if(imported_lib)
      list(APPEND all_depends ${imported_lib})
    endif()
    list(REMOVE_ITEM all_depends "${target}")
  endforeach()

  list(REMOVE_DUPLICATES all_sources)
  set_target_properties(${name} PROPERTIES SOURCES "${all_sources}")

  list(REMOVE_DUPLICATES all_incs)
  set_target_properties(${name} PROPERTIES INCLUDE_DIRECTORIES "${all_incs}")

  if(NOT all_depends)
    set(all_depends "")
  endif()
  list(REMOVE_DUPLICATES all_depends)
  arcbuild_echo("Prebuilt dependencies of ${name}:")
  foreach(dep ${all_depends})
    arcbuild_echo("- ${dep}")
  endforeach()
  set_target_properties(${name} PROPERTIES LINK_LIBRARIES "${all_depends}")
endfunction()

function(arcbuild_type var_name name)
  if(TARGET "${name}")
    get_target_property(build_type ${name} TYPE)
  else()
    if(name MATCHES "\\.(a|lib)$")
      set(build_type "STATIC_LIBRARY")
    elseif(name MATCHES "\\.(dll|so|dylib)$")
      set(build_type "SHARED_LIBRARY")
    else()
      set(build_type "EXECUTABLE")
    endif()
  endif()
  if(build_type)
    set(${var_name} ${build_type} PARENT_SCOPE)
  endif()
endfunction()

function(arcbuild_install_prebuilt_libraries name destination)
  arcbuild_collect_link_libraries(all_depends ${name})
  get_target_property(build_type ${name} TYPE)
  foreach(depend ${all_depends})
    arcbuild_type(target_build_type "${depend}")
    set(install_it)
    if(build_type STREQUAL "STATIC_LIBRARY")
      if(target_build_type MATCHES "LIBRARY$")
        set(install_it 1)
      endif()
    else()
      if(target_build_type STREQUAL "SHARED_LIBRARY$")
        set(install_it 1)
      endif()
    endif()
    if(install_it AND NOT TARGET "${depend}" AND NOT depend MATCHES "mpbase\\.(a|so|lib|dll|dylib)$")
      arcbuild_echo("- Install prebuilt: ${depend}")
      install(FILES ${depend} DESTINATION "${destination}")
    endif()
  endforeach()
endfunction()

function(arcbuild_find_file var_name)
  cmake_parse_arguments(A
    "NO_DEFAULT_PATH" # options
    "" # single value
    "NAMES;PATHS" # multiple values
    ${ARGN}
  )
  if(EXISTS ${var_name})
    return()
  endif()
  foreach(path ${A_PATHS})
    foreach(name ${A_NAMES})
      set(full_path "${path}/${name}")
      if(EXISTS "${full_path}")
        set(found 1)
        break()
      endif()
    endforeach()
    if(found)
      break()
    endif()
  endforeach()
  if(found)
    set(${var_name} "${full_path}" CACHE FILEPATH "Path to a file")
    set(${var_name} "${full_path}" PARENT_SCOPE)
  endif()
endfunction()

function(arcbuild_find_path var_name)
  cmake_parse_arguments(A
    "NO_DEFAULT_PATH" # options
    "" # single value
    "NAMES;PATHS" # multiple values
    ${ARGN}
  )
  if(EXISTS ${var_name})
    return()
  endif()
  foreach(path ${A_PATHS})
    foreach(name ${A_NAMES})
      set(full_path "${path}/${name}")
      if(EXISTS "${full_path}")
        set(result_path "${path}")
        set(found 1)
        break()
      endif()
    endforeach()
    if(found)
      break()
    endif()
  endforeach()
  if(found)
    set(${var_name} "${result_path}" CACHE PATH "Path to a directory")
    set(${var_name} "${result_path}" PARENT_SCOPE)
  endif()
endfunction()

function(arcbuild_check_cmake_version)
  set(required_cmake_version "2.8.12")
  if(NOT ARCBUILD_CMAKE_VERSION_CHECKED AND CMAKE_VERSION VERSION_LESS ${required_cmake_version})
    arcbuild_error("Required CMake version >= ${required_cmake_version}")
    set(ARCBUILD_CMAKE_VERSION_CHECKED ON PARENT_SCOPE)
  endif()
endfunction()

set(ARCBUILD_DIR "${CMAKE_CURRENT_LIST_DIR}")
arcbuild_check_cmake_version()
