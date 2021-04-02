function(equil_setup in_dir out_dir name label)

cmake_path(APPEND nml_file ${in_dir} config.nml)

parse_nml(${nml_file} "eq_dir" "path")
if(NOT eq_dir)
  message(FATAL_ERROR "${name}: missing eq_dir in ${nml_file}")
endif()
cmake_path(GET eq_dir FILENAME eq_name)
if(NOT eq_name)
  message(FATAL_ERROR "${name}: ${eq_dir} seems malformed, could not get directory name.")
endif()



add_test(NAME "setup:download_eq:${name}"
  COMMAND ${CMAKE_COMMAND} -Deq_dir:PATH=${eq_dir} -Dname=${name} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/download_eq.cmake)

  set_tests_properties("setup:download_eq:${name}" PROPERTIES
  LABELS "download;${label}"
  REQUIRED_FILES ${in_dir}/config.nml
  DISABLED $<NOT:$<BOOL:${eq_dir}>>
  TIMEOUT 1800
  FIXTURES_SETUP ${name}:eq_fxt
  RESOURCE_LOCK ${eq_name}_download)


endfunction(equil_setup)
