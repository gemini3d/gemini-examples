function(equil_setup in_dir out_dir)

set(nml_file ${in_dir}/config.nml)

parse_nml(${nml_file} "eq_dir" "path")

add_test(NAME "setup:download_eq:${name}"
  COMMAND ${CMAKE_COMMAND} -Dnml_file:FILEPATH=${nml_file} -Deq_dir:PATH=${eq_dir} -Dname=${name} -Dout_dir:PATH=${out_dir} -P ${CMAKE_CURRENT_LIST_DIR}/cmake/download_eq.cmake)
set_tests_properties("setup:download_eq:${name}" PROPERTIES
  LABELS "download;${label}"
  REQUIRED_FILES ${in_dir}/config.nml
  DISABLED $<NOT:$<BOOL:${eq_dir}>>
  TIMEOUT 300
  FIXTURES_SETUP ${name}:eq_fxt)


endfunction(equil_setup)
