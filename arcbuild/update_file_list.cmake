function(arcbuild_get_file_list var_name root)
  file(GLOB names LIST_DIRECTORIES true RELATIVE "${root}" "${root}/*" )
  set(prefix ${ARGN})
  foreach(name ${names})
    set(line "${prefix}|---${name}")
    set(path "${root}/${name}")
    set(file_list "${file_list}${line}\n")
    if(IS_DIRECTORY "${path}")
      arcbuild_get_file_list(file_list "${path}" "${prefix}|    ")
    else()
      get_filename_component(ext ${path} EXT)
      string(TOLOWER ${ext} ext)
      if(${ext} MATCHES  "\\.(h|hpp)")
        set(comment "Head file")
      elseif(ext MATCHES "\\.(c|cpp)")
        set(comment "Sample codes")
      elseif(ext MATCHES "\\.pdf")
        set(comment "Developer's guide")
      elseif(ext MATCHES "\\.(a|so|lib|dll)")
        set(comment "Library")
      endif()
      if(comment)
        string(LENGTH "${line}" line_len)
        math(EXPR null_len "60-${line_len}")
        while(null_len GREATER 0)
          set(comment " ${comment}")
          math(EXPR null_len "${null_len}-1")
        endwhile()
        string(REGEX REPLACE "\n$" "${comment}\n" file_list "${file_list}")
      endif()
    endif()
  endforeach()
  set(${var_name} "${file_list}" PARENT_SCOPE)
endfunction()


function(arcbuild_update_file_list root path)
  message(STATUS "Updating file list: ${root}")

  # generate file list
  arcbuild_get_file_list(file_list "${root}")
  string(STRIP "${file_list}" file_list)

  file(READ "${path}" content)
  string(REGEX REPLACE "(File List:[ \r\n]+)[^\r\n]+" "\\1${file_list}" content "${content}")
  file(WRITE "${path}" ${content})
endfunction()


#cmakedefine ARCBUILD_UPDATE_FILE_LIST ON
if(ARCBUILD_UPDATE_FILE_LIST)
  # include(@ARCBUILD_DIR@/core.cmake)
  arcbuild_update_file_list(
    "${CMAKE_INSTALL_PREFIX}/@PACKAGE_NAME@"
    "${CMAKE_INSTALL_PREFIX}/@PACKAGE_NAME@/@RELEASE_NOTES@"
  )
endif()
