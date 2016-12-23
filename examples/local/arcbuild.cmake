# Prepare ARCBUILD_ROOT_DIR and ARCBUILD_DIR
if(NOT ARCBUILD_ROOT_DIR)
  set(ARCBUILD_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")
endif()
set(ARCBUILD_DIR "${ARCBUILD_ROOT_DIR}/arcbuild")

# Download build script if not existed
if(NOT EXISTS "${ARCBUILD_DIR}/core.cmake")
  set(ARCBUILD_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/_arcbuild")
  set(ARCBUILD_DIR "${ARCBUILD_ROOT_DIR}/arcbuild")
  if(NOT EXISTS "${ARCBUILD_DIR}/core.cmake")
    file(DOWNLOAD "http://172.17.10.213/lny1856/arcbuild2/raw/master/arcbuild/upgrade.cmake" "${ARCBUILD_DIR}/upgrade.cmake")
    include(${ARCBUILD_DIR}/upgrade.cmake)
    arcbuild_upgrade("${ARCBUILD_ROOT_DIR}")
  endif()
endif()

include(${ARCBUILD_DIR}/boot.cmake)
