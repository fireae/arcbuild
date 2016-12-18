include(${ARCBUILD_ROOT_DIR}/arcbuild.cmake)


function(arcbuild_get_platform_code var_name)
  set(code "00" "[unknow_arch]")
  if(ANDROID)
    set(code "120" "android")
  elseif(IOS)
    if(SDK_API_VERSION VERSION_GREATER "8")
      set(code "167" "ios8")
    elseif(SDK_API_VERSION VERSION_GREATER "7")
      set(code "166" "ios7")
    elseif(SDK_API_VERSION VERSION_GREATER "6")
      set(code "164" "ios6")
    elseif(SDK_API_VERSION VERSION_GREATER "5")
      set(code "163" "ios5")
    else()
      set(code "163" "ios")
    endif()
  elseif(TIZEN)
    set(code "107" "tizen")
  elseif(COACH)
    set(code "124" "coach")
  elseif(LINUX)
    set(code "124" "linux")
  elseif(MSVC)
    if(MSVC14) # vs2015
      set(code "41" "vs2015")
    elseif(MSVC12) # vs2013
      set(code "39" "vs2013")
    elseif(MSVC11) # vs2012
      set(code "37" "vs2012")
    elseif(MSVC10) # vs2010
      set(code "38" "vs2010")
    elseif(MSVC90) # vs2008
      set(code "36" "vs2008")
    elseif(MSVC80) # vs2005
      set(code "31" "vs2005")
    elseif(MSVC60) # vc6
      set(code "30" "vc6")
    endif()
    # list(INSERT code 1 "windows")
  endif()
  set(${var_name} ${code} PARENT_SCOPE)
endfunction()


function(arcbuild_get_arch_code var_name)
  set(code "00" "[unkown_platform]")
  if(SDK_ARCH)
    if("armv8" IN_LIST SDK_ARCH)
      set(code "23")
    elseif("armv8-a" IN_LIST SDK_ARCH)
      set(code "23")
    elseif("arm64" IN_LIST SDK_ARCH)
      set(code "23")
    elseif("armv7" IN_LIST SDK_ARCH)
      set(code "21")
    elseif("armv7s" IN_LIST SDK_ARCH)
      set(code "21")
    elseif("armv7-a" STREQUAL SDK_ARCH)
      set(code "21")
    elseif("arm" STREQUAL SDK_ARCH)
      set(code "10")
    elseif("x64" STREQUAL SDK_ARCH)
      set(code "02")
    elseif("x86" STREQUAL SDK_ARCH)
      set(code "00")
    endif()
    set(code ${code} ${SDK_ARCH})
  else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(code "00" "x86")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(code "02" "x64")
    endif()
  endif()
  set(${var_name} ${code} PARENT_SCOPE)
endfunction()


function(arcbuild_get_platform_number var_name)
  arcbuild_get_platform_code(platform_code)
  arcbuild_get_arch_code(arch_code)
  list(GET platform_code 0 platform_code)
  list(GET arch_code 0 arch_code)
  set(${var_name} "${platform_code}${arch_code}" PARENT_SCOPE)
endfunction()


function(arcbuild_get_full_version var_name v_major v_minor v_build)
  arcbuild_get_platform_number(v_platorm)
  set(${var_name} "${v_major}.${v_minor}.${v_platorm}.${v_build}" PARENT_SCOPE)
endfunction()


function(split_version var_name version)
  string(REPLACE "." ";" var_name ${version})
endfunction()


function(arcbuild_get_build_type var_name name)
  get_target_property(build_type ${name} TYPE)
  if(build_type STREQUAL "STATIC_LIBRARY")
    set(build_type "static")
  elseif(build_type STREQUAL "SHARED_LIBRARY")
    set(build_type "shared")
  else()
    arcbuild_error("Unknown build type of target \"${name}\": ${build_type}")
  endif()
  set(${var_name} ${build_type} PARENT_SCOPE)
endfunction()


function(join var_name sep)
  string(REGEX REPLACE "([^\\]|^);" "\\1${sep}" result "${ARGN}")
  string(REGEX REPLACE "[\\](.)" "\\1" result "${result}") #fixes escaping
  set(${var_name} "${result}" PARENT_SCOPE)
endfunction()


function(arcbuild_get_abi_name var_name)
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
  list(GET platform 0 platform_name)
  if(platfor_name STREQUAL "android")
    if(arch STREQUAL "arm")
      set(abi_name "armeabi")
    elseif(arch STREQUAL "armv7-a")
      set(abi_name "armeabi-v7a")
    elseif(arch STREQUAL "arm64")
      set(abi_name "arm64-v8a")
    endif()
  else()
    join(abi_name "_" ${platform} ${arch})
  endif()
  set(${var_name} ${abi_name} PARENT_SCOPE)
endfunction()


function(arcbuild_get_package_name var_name name version build_type)
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
  join(platform "_" ${platform})
  join(arch "_" ${arch})
  set(package_name "${name}_${version}_${platform}_${arch}_${build_type}")
  if(ARCBUILD_CUSTOMER)
    set(package_name "${package_name}_FOR_${ARCBUILD_CUSTOMER}")
  endif()
  string(TIMESTAMP current_date "%m%d%Y")
  set(package_name "${package_name}_${current_date}")
  if(ARCBUILD_SUFFIX)
    set(package_name "${package_name}${ARCBUILD_SUFFIX}")
  endif()
  string(TOUPPER ${package_name} package_name)
  set(${var_name} ${package_name} PARENT_SCOPE)
endfunction()


function(arcbuild_update_version_file name path version)
  arcbuild_echo("Read version file: ${path}")
  file(READ ${path} content)
  string(TIMESTAMP current_date "%m/%d/%Y")
  string(TIMESTAMP current_year "%Y")
  string(REPLACE "." ";" version_numbers ${version})
  list(GET version_numbers 0 v_major)
  list(GET version_numbers 1 v_minor)
  list(GET version_numbers 3 v_build)
  string(REGEX REPLACE "(#define VERSION_MAJOR[ \t]+)([0-9]+)" "\\1${v_major}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_MINOR[ \t]+)([0-9]+)" "\\1${v_minor}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_BUILD[ \t]+)([0-9]+)" "\\1${v_build}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_DATE[ \t]+)([0-9/]+)" "\\1${current_date}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_VERSION[^0-9.]+)([0-9.]+)" "\\1${version}" content "${content}")
  string(REGEX REPLACE "(#define VERSION_COPYRIGHT.+)([1-2][0-9][0-9][0-9])" "\\1${current_year}" content "${content}")
  get_target_property(sources ${name} SOURCES)
  get_filename_component(base_name ${path} NAME)
  get_filename_component(full_path ${path} REALPATH)
  set(new_path "${PROJECT_BINARY_DIR}/generated_${base_name}")
  list(REMOVE_ITEM sources ${full_path})
  arcbuild_echo("Generate version file: ${new_path}")
  file(WRITE ${new_path} "${content}")
  list(APPEND sources ${new_path})
  set_target_properties(${name} PROPERTIES SOURCES "${sources}")
endfunction()

function(arcbuild_get_compile_flags var_name name)
  set(flags ${CMAKE_CXX_FLAGS})
  get_target_property(custom_flags ${name} COMPILE_FLAGS)
  if(custom_flags)
    set(flags "${flags} ${custom_flags}")
  endif()

  # Remove paths
  string(REGEX REPLACE "\"[^\"]+\"" "" flags "${flags}")

  # Filter some flags
  set(flitered_flags)
  foreach(flag ${flags})
  endforeach()
  string(STRIP ${flags} flags)
  # message(${flags})

  set(${var_name} ${flags} PARENT_SCOPE)
endfunction()

function(arcbuild_update_releasenotes name new_path path version)
  arcbuild_get_compile_flags(flags ${name})
  string(TIMESTAMP current_date "%Y/%m/%d")
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
  join(platform "_" ${platform})
  join(arch "_" ${arch})
  file(READ ${path} content)
  string(REGEX REPLACE "(Publish date:[ \r\n]+)[^\r\n]+" "\\1${current_date}" content "${content}")
  string(REGEX REPLACE "(Version:[ \r\n]+)[^\r\n]+" "\\1${version}" content "${content}")
  string(REGEX REPLACE "(Supported platforms:[ \r\n]+)[^\r\n]+" "\\1${platform}_${arch}" content "${content}")
  string(REGEX REPLACE "(Compile Option:[ \r\n]+)[^\r\n]+" "\\1${flags}" content "${content}")
  file(WRITE ${new_path} "${content}")
  # message(${content})
endfunction()

function(arcbuild_define_arcsoft_sdk name)
  # Parse arguments
  set(args_option_args)
  set(args_single_value_args LIBRARY VERSION_FILE RELEASE_NOTES)
  set(args_multiple_values_args INCS DOCS SAMPLE_CODE)
  cmake_parse_arguments(A
    "${args_option_args}" # options
    "${args_single_value_args}" # single value
    "${args_multiple_values_args}" # multiple values
    ${ARGN}
  )
  file(GLOB A_INCS ${A_INCS})
  file(GLOB A_DOCS ${A_DOCS})
  # get_target_property(A_SAMPLE_CODE ${A_SAMPLE_CODE} SOURCES)
  arcbuild_echo("Define ArcSoft SDK: ${name}")
  arcbuild_echo("  Target library: ${A_LIBRARY}")
  arcbuild_echo("  Include headers: ${A_INCS}")
  arcbuild_echo("  Version file: ${A_VERSION_FILE}")
  arcbuild_echo("  Sample code: ${A_SAMPLE_CODE}")
  arcbuild_echo("  Relasenotes: ${A_RELEASE_NOTES}")
  arcbuild_echo("  Docs: ${A_DOCS}")

  # Get version
  set(v_major 1)
  set(v_minor 2)
  set(v_build 3)
  arcbuild_get_full_version(version ${v_major} ${v_minor} ${v_build})

  # Update version file
  arcbuild_update_version_file(${name} ${A_VERSION_FILE} ${version})

  # Update releasenotes
  get_filename_component(rlsnote_base_name "${A_RELEASE_NOTES}" NAME)
  set(NEW_RELEASE_NOTES_PATH "${PROJECT_BINARY_DIR}/${rlsnote_base_name}")
  arcbuild_update_releasenotes(${name} ${NEW_RELEASE_NOTES_PATH} ${A_RELEASE_NOTES} ${version})

  # Package name
  arcbuild_get_build_type(build_type ${name})
  arcbuild_get_package_name(package_name ${name} ${version} ${build_type})
  arcbuild_echo("Package name: ${package_name}")

  # ABI name
  arcbuild_get_abi_name(abi_name)
  arcbuild_echo("ABI name: ${abi_name}")

  # Install targets
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Install path prefix" FORCE)
  install(FILES ${A_INCS} DESTINATION ${package_name}/inc)
  install(FILES ${A_SAMPLE_CODE} DESTINATION ${package_name}/samplecode)
  install(FILES ${A_DOCS} DESTINATION ${package_name}/doc)
  install(FILES ${NEW_RELEASE_NOTES_PATH} DESTINATION ${package_name})
  install(TARGETS ${A_LIBRARY} DESTINATION ${package_name}/lib/${abi_name})

  # Update filelist releasenotes
  set(RELEASE_NOTES_PATH "${CMAKE_INSTALL_PREFIX}/${package_name}/${rlsnote_base_name}")
  set(install_script "${PROJECT_BINARY_DIR}/update_file_list.cmake")
  configure_file("${ARCBUILD_ROOT_DIR}/plugins/update_file_list.cmake" ${install_script} @ONLY)
  install(SCRIPT "${install_script}")

  # debug
  # include(${ARCBUILD_ROOT_DIR}/plugins/update_file_list.cmake)
  # arcbuild_update_file_list("${CMAKE_INSTALL_PREFIX}/${package_name}" "${RELEASE_NOTES_PATH}")

  # CPack settings
  set(CPACK_PACKAGE_FILE_NAME ${package_name})
  set(CPACK_GENERATOR ZIP)
  include(CPack)
endfunction()
