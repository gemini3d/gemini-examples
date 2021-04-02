function(input_setup in_dir out_dir name label)

cmake_path(APPEND nml_file ${in_dir} config.nml)

# get equilibrium directory
parse_nml(${nml_file} "eq_dir" "path")
if(NOT eq_dir)
  message(FATAL_ERROR "${name}: missing eq_dir in ${nml_file}")
endif()

string(REGEX REPLACE "[\\/]+$" "" eq_dir "${eq_dir}") # must strip trailing slash for cmake_path(... FILENAME) to work

cmake_path(GET eq_dir FILENAME eq_name)
if(NOT eq_name)
  message(FATAL_ERROR "${name}: ${eq_dir} seems malformed, could not get directory name ${eq_name}")
endif()

add_test(NAME "setup:download_equilibrium:${name}"
COMMAND ${CMAKE_COMMAND} -Dinput_dir:PATH=${eq_dir} -Dname=${name} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/download_input.cmake)

set_tests_properties("setup:download_equilibrium:${name}" PROPERTIES
LABELS "download;${label}"
REQUIRED_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/reference_url.json
TIMEOUT 1800
FIXTURES_SETUP ${name}:eq_fxt
RESOURCE_LOCK ${eq_name}_eq_download_lock)  # avoids two tests trying to download same file at same time

# get neutral input directory, if present
parse_nml(${nml_file} "source_dir" "path")
if(NOT source_dir)
  return()
endif()

add_test(NAME "setup:download_neutral:${name}"
COMMAND ${CMAKE_COMMAND} -Dinput_dir:PATH=${source_dir} -Dname=${name} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/download_input.cmake)

set_tests_properties("setup:download_neutral:${name}" PROPERTIES
LABELS "download;${label}"
REQUIRED_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/reference_url.json
TIMEOUT 300
FIXTURES_SETUP ${name}:eq_fxt  # no need for distinct fixture
RESOURCE_LOCK ${eq_name}_neutral_download_lock)



endfunction(input_setup)
