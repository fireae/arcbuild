# The MIT License (MIT)
# Copyright © 2016 Naiyang Lin <maxint@foxmail.com>

function(arcbuild_echo)
  message(STATUS "ARCBUILD [I] ${ARGN}")
endfunction()

function(arcbuild_upgrade target_dir)
  set(url_root "http://172.17.10.213/lny1856/arcbuild2/raw/master")
  arcbuild_echo("Upgrading arcbuild to: ${target_dir} ...")
  foreach(name
arcsoft_sdk.cmake
boot.cmake
build.cmake
core.cmake
mpbase.cmake
update_file_list.cmake
upgrade.cmake)
    set(sub_path "arcbuild/${name}")
    file(DOWNLOAD "${url_root}/${sub_path}" "${target_dir}/${sub_path}")
  endforeach()
  foreach(name
android-ndk.cmake
ctc.cmake
gcc-arm-linux.cmake
gcc-linux-sysroot.cmake
gcc-version.cmake
ios-xcode.cmake
tizen1.0.cmake
tizen2.2.cmake)
    set(sub_path "toolchains/${name}")
    file(DOWNLOAD "${url_root}/${sub_path}" "${target_dir}/${sub_path}")
  endforeach()
  arcbuild_echo("Upgrading arcbuild [DONE]")
  set(ARCBUILD_ROOT_DIR "${target_dir}" PARENT_SCOPE)
  set(ARCBUILD_DIR "${ARCBUILD_ROOT_DIR}/arcbuild" PARENT_SCOPE)
endfunction()
