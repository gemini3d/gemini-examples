cmake_minimum_required(VERSION 3.18...3.20)

include(${CMAKE_CURRENT_LIST_DIR}/parse_nml.cmake)


function(download_eq in_dir name out_dir)

set(nml_file ${in_dir}/config.nml)

parse_nml(${nml_file} "eq_dir")
if(NOT eq_dir)
  message(FATAL_ERROR "${name}: ${nml_file} does not specify eq_dir")
endif()

get_filename_component(eq_dir ${out_dir}/${eq_dir} ABSOLUTE)
if(EXISTS ${eq_dir}/inputs/config.nml)
  return()
endif()

parse_nml(${nml_file} "eq_url")
if(NOT eq_url)
  message(FATAL_ERROR "${name}: ${nml_file} does not define eq_url, and ${eq_dir} is not a directory.")
endif()

parse_nml(${nml_file} "eq_zip")
if(NOT eq_zip)
  get_filename_component(eq_zip ${eq_dir} NAME)
  set(eq_zip ${eq_zip}.zip)
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


download_eq(${in_dir} ${name} ${out_dir})
