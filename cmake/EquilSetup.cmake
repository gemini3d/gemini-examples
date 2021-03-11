function(equil_setup in_dir equil_dirs out_dir)

if(NOT ${in_dir} IN_LIST equil_dirs)
  add_test(NAME "setup:download_eq:${name}"
    COMMAND ${CMAKE_COMMAND} -Din_dir:PATH=${in_dir} -Dname=${name} -Dout_dir:PATH=${out_dir} -P ${CMAKE_CURRENT_LIST_DIR}/cmake/download_eq.cmake)
  set_tests_properties("setup:download_eq:${name}" PROPERTIES
    LABELS "download;${label}"
    REQUIRED_FILES ${in_dir}/config.nml
    TIMEOUT 300
    FIXTURES_SETUP ${name}:eq_fxt)
endif()


endfunction(equil_setup)
