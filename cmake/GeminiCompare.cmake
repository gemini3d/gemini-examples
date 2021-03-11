function(gemini_compare compare_exe out_dir ref_root name label)

set(ref_dir ${ref_root}/test${name})

add_test(NAME compare:download:${name}
  COMMAND ${CMAKE_COMMAND} -Dtestname=${name} -Doutdir:PATH=${out_dir} -Drefroot:PATH=${ref_root} -P ${CMAKE_CURRENT_LIST_DIR}/cmake/download_ref.cmake)
set_tests_properties(compare:download:${name} PROPERTIES
  FIXTURES_SETUP ${name}:compare_fxt
  FIXTURES_REQUIRED ${name}:run_fxt
  LABELS "download;${label}"
  TIMEOUT 180)

set(compare_cmd ${compare_exe} ${out_dir} ${ref_dir})

add_test(NAME "compare:${name}" COMMAND ${compare_cmd})

set_tests_properties("compare:${name}" PROPERTIES
  DISABLED $<NOT:$<BOOL:${compare_exe}>>
  LABELS "compare;${label}"
  FIXTURES_REQUIRED ${name}:compare_fxt
  FIXTURES_SETUP ${name}:package_fxt
  TIMEOUT 300)

endfunction(gemini_compare)
