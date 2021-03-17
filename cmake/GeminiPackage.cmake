function(gemini_package GEMINI_SIMROOT name label)

string(TIMESTAMP ts "%Y-%m-%d" UTC)

set(upload_root ${GEMINI_SIMROOT}/upload-${ts})

file(MAKE_DIRECTORY ${upload_root})

set(archive ${upload_root}/${name}.zstd)
set(data_dir ${GEMINI_SIMROOT}/${name})

add_test(NAME "package:${name}"
  COMMAND ${CMAKE_COMMAND} -Din:PATH=${data_dir} -Dout:FILEPATH=${archive} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/zip.cmake)

set_tests_properties("package:${name}" PROPERTIES
  FIXTURES_REQUIRED ${name}:package_fxt
  LABELS "package;${label}"
  REQUIRED_FILES "${data_dir}/inputs/config.nml;${data_dir}/output.nml"
  TIMEOUT 120)

endfunction(gemini_package)
