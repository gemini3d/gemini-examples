function(gemini_compare compare_exe out_dir ref_root name label)

cmake_path(APPEND ref_dir ${ref_root} ${name})

add_test(NAME compare:download:${name}
  COMMAND ${CMAKE_COMMAND} -Dname=${name} -Dref_root:PATH=${ref_root} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/download_ref.cmake)
set_tests_properties(compare:download:${name} PROPERTIES
  FIXTURES_SETUP ${name}:compare_fxt
  FIXTURES_REQUIRED ${name}:run_fxt
  REQUIRED_FILES "${out_dir}/inputs/config.nml;${out_dir}/output.nml"
  LABELS "download;${label}"
  TIMEOUT 180)

set(compare_cmd ${compare_exe} ${out_dir} ${ref_dir})

add_test(NAME compare:${name} COMMAND ${compare_cmd})

set_tests_properties(compare:${name} PROPERTIES
  DISABLED $<NOT:$<BOOL:${compare_exe}>>
  LABELS "compare;${label}"
  FIXTURES_REQUIRED ${name}:compare_fxt
  FIXTURES_SETUP ${name}:package_fxt
  TIMEOUT 300)

endfunction(gemini_compare)
