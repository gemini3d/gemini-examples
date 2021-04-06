function(compare_output compare_exe out_dir ref_root name label)

cmake_path(APPEND ref_dir ${ref_root} ${name})

add_test(NAME compare:output:${name}
COMMAND ${compare_exe} ${out_dir} ${ref_dir} -which out)

set_tests_properties(compare:output:${name} PROPERTIES
DISABLED $<NOT:$<BOOL:${compare_exe}>>
LABELS "compare;${label}"
FIXTURES_REQUIRED "${name}:run_fxt;${name}:compare_fxt"
FIXTURES_SETUP ${name}:package_fxt
TIMEOUT 300
ENVIRONMENT GEMINI_SIMROOT=${GEMINI_SIMROOT})

endfunction(compare_output)


function(compare_input compare_exe out_dir ref_root name label)

cmake_path(APPEND ref_dir ${ref_root} ${name})

add_test(NAME compare:input:${name}
COMMAND ${compare_exe} ${out_dir} ${ref_dir} -which in)

set_tests_properties(compare:input:${name} PROPERTIES
DISABLED $<NOT:$<BOOL:${compare_exe}>>
LABELS "compare;${label}"
FIXTURES_REQUIRED ${name}:compare_fxt
FIXTURES_SETUP ${name}:package_fxt
TIMEOUT 300
ENVIRONMENT GEMINI_SIMROOT=${GEMINI_SIMROOT})

endfunction(compare_input)


function(compare_download out_dir ref_root name label)

add_test(NAME compare:download:${name}
COMMAND ${CMAKE_COMMAND} -Dname=${name} -Dref_root:PATH=${ref_root} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/download_ref.cmake)

set_tests_properties(compare:download:${name} PROPERTIES
FIXTURES_SETUP ${name}:compare_fxt
FIXTURES_REQUIRED ${name}:setup_fxt
REQUIRED_FILES "${out_dir}/inputs/config.nml;${out_dir}/output.nml"
LABELS "download;${label}"
RESOURCE_LOCK ${name}_compare_download_lock
TIMEOUT 180)

endfunction(compare_download)
