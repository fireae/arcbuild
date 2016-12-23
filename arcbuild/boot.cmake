include(${ARCBUILD_DIR}/core.cmake)


function(arcbuild_parse_cmake_arguments var_name)
  list(REMOVE_ITEM ARGN "cmake")
  list(REMOVE_ITEM ARGN "-P")
  list(REMOVE_ITEM ARGN "arcbuild.cmake")
  set(results)
  foreach(argv ${ARGN})
    if(argv MATCHES "(cmake|cmake.exe)$")
      continue()
    else()
      list(APPEND results ${argv})
    endif()
  endforeach()
  set(${var_name} ${results} PARENT_SCOPE)
endfunction()


# Get argumetns from cmake calling
arcbuild_get_cmake_argv(arguments)


# Check whether called by "cmake -P arcbuild.cmake"
list(FIND arguments "-P" ret)
if(ret EQUAL -1)
  unset(arguments)
  unset(ret)
  include(${ARCBUILD_DIR}/core.cmake)
else()
  arcbuild_parse_cmake_arguments(arguments ${arguments})
  unset(ret)
  include(${ARCBUILD_DIR}/build.cmake)
  arcbuild_build(${arguments})
endif()
