include(${CMAKE_CURRENT_LIST_DIR}/parse_nml.cmake)

function(download_extract nml_file)

parse_nml("${nml_file}" "eq_url")
if(NOT eq_url)
  message(WARNING "${nml_file} does not define eq_url, and ${eq_dir} is not a directory.")
  return()
endif()

parse_nml("${nml_file}" "eq_zip")
if(NOT eq_zip)
  get_filename_component(eq_zip ${eq_dir} NAME)
  set(eq_zip ${eq_zip}.zip)
endif()
get_filename_component(eq_zip ${eq_zip} ABSOLUTE)

if(NOT EXISTS ${eq_zip})
  message(STATUS "${eq_url} => ${eq_zip}")
  file(DOWNLOAD ${eq_url} ${eq_zip} TLS_VERIFY ON)
endif()

message(STATUS "${eq_zip} => ${eq_dir}")
get_filename_component(eq_root ${eq_dir} DIRECTORY)

if(CMAKE_VERSION VERSION_LESS 3.18)
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${eq_zip} WORKING_DIRECTORY ${eq_root})
else()
  file(ARCHIVE_EXTRACT INPUT ${eq_zip} DESTINATION ${eq_root})
endif()

endfunction(download_extract)


# download_extract("${nml_file}")
