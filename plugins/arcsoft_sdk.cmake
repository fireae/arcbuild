include(${CMAKE_CURRENT_LIST_DIR}/../arcbuild.cmake)

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
  elseif(TIZEN)
    set(code "107" "tizen")
  elseif(COACH)
    set(code "124" "coach")
  elseif(LINUX)
    set(code "124" "linux")
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


function(arcbuild_get_package_name var_name name version build_type)
  arcbuild_get_platform_code(platform)
  arcbuild_get_arch_code(arch)
  list(REMOVE_AT platform 0)
  list(REMOVE_AT arch 0)
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


function(arcbuild_)

endfunction()


function(arcbuild_update_version_file path v_major v_minor v_build)
  arcbuild_echo("Updating version file: ${path}")
  file(READ ${path} content)
  string(TIMESTAMP current_date "%m/%d/%Y")
  string(TIMESTAMP current_year "%Y")
  arcbuild_get_full_version(version ${v_major} ${v_minor} ${v_build})
  string(REGEX REPLACE "(#define VERSION_MAJOR[^0-9]+)([0-9]+)" "\\1${v_major}" content ${content})
  string(REGEX REPLACE "(#define VERSION_MINOR[^0-9]+)([0-9]+)" "\\1${v_minor}" content ${content})
  string(REGEX REPLACE "(#define VERSION_BUILD[^0-9]+)([0-9]+)" "\\1${v_build}" content ${content})
  string(REGEX REPLACE "(#define VERSION_DATE[^0-9/]+)([0-9/]+)" "\\1${current_date}" content ${content})
  string(REGEX REPLACE "(#define VERSION_DATE[^0-9/]+)([0-9/]+)" "\\1${current_date}" content ${content})
  string(REGEX REPLACE "(#define VERSION_VERSION[^0-9.]+)([0-9.]+)" "\\1${version}" content ${content})
  string(REGEX REPLACE "(#define VERSION_COPYRIGHT.+)([1-2][0-9][0-9][0-9])" "\\1${current_year}" content ${content})
  #file(WRITE ${path} ${content})
  message(${content})
endfunction()


function(arcbuild_define_arcsoft_sdk name)
  # Parse arguments
  set(args_option_args)
  set(args_single_value_args LIBRARY VERSION_FILE RELEASE_NOTES)
  set(args_multiple_values_args INCS DOCS)
  cmake_parse_arguments(A
    "${args_option_args}" # options
    "${args_single_value_args}" # single value
    "${args_multiple_values_args}" # multiple values
    ${ARGN}
  )
  file(GLOB A_INCS ${A_INCS})
  file(GLOB A_DOCS ${A_DOCS})
  arcbuild_echo("Define ArcSoft SDK: ${name}")
  arcbuild_echo("  Target library: " ${A_LIBRARY})
  arcbuild_echo("  Include headers: " ${A_INCS})
  arcbuild_echo("  Version file: " ${A_VERSION_FILE})
  arcbuild_echo("  Relasenotes: " ${A_RELEASE_NOTES})
  arcbuild_echo("  Docs: " ${A_DOCS})

  # Get version
  set(v_major 1)
  set(v_minor 2)
  set(v_build 3)

  # Update version file
  arcbuild_update_version_file(${A_VERSION_FILE} ${v_major} ${v_minor} ${v_build})

  # Package name
  arcbuild_get_full_version(version ${v_major} ${v_minor} ${v_build})
  arcbuild_get_build_type(build_type ${name})
  arcbuild_get_package_name(package_name ${name} ${version} ${build_type})

  # Install targets
  install(FILES )
endfunction()
