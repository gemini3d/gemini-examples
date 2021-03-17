include(${CMAKE_CURRENT_LIST_DIR}/parse_nml.cmake)

set(ARC_TYPE zstd)


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
  get_filename_component(eq_zip ${eq_dir} NAME)
  set(eq_zip ${eq_zip}.${ARC_TYPE})
endif()
get_filename_component(eq_zip ${eq_zip} ABSOLUTE)

if(NOT EXISTS ${eq_zip})
  message(STATUS "DOWNLOAD: ${eq_url} => ${eq_zip}")
  file(DOWNLOAD ${eq_url} ${eq_zip} TLS_VERIFY ON)
endif()

get_filename_component(eq_root ${eq_dir} DIRECTORY)
message(STATUS "EXTRACT: ${eq_zip} => ${eq_root}")
file(ARCHIVE_EXTRACT INPUT ${eq_zip} DESTINATION ${eq_root})

endfunction(download_eq)


download_eq(${nml_file} ${eq_dir} ${name} ${GEMINI_SIMROOT})
