include(${CMAKE_CURRENT_LIST_DIR}/parse_nml.cmake)


function(download_eq nml_file eq_dir name GEMINI_SIMROOT)

if(EXISTS ${eq_dir}/inputs/config.nml AND EXISTS ${eq_dir}/output.nml)
  # already present
  return()
endif()

parse_nml(${nml_file} "eq_url" "path")
if(NOT eq_url)
  message(FATAL_ERROR "${name}: ${nml_file} does not define eq_url, and ${eq_dir} is not a directory.")
endif()

parse_nml(${nml_file} "eq_zip" "path")
if(NOT eq_zip)
  message(FATAL_ERROR "${name}: ${nml_file} does not define eq_zip, which is needed to extract download from ${eq_url}")
endif()

if(NOT EXISTS ${eq_zip})
  message(STATUS "DOWNLOAD: ${eq_url} => ${eq_zip}")
  file(DOWNLOAD ${eq_url} ${eq_zip} TLS_VERIFY ON)
endif()

message(STATUS "EXTRACT: ${eq_zip} => ${eq_dir}")
file(ARCHIVE_EXTRACT INPUT ${eq_zip} DESTINATION ${eq_dir})

endfunction(download_eq)


download_eq(${nml_file} ${eq_dir} ${name} ${GEMINI_SIMROOT})
