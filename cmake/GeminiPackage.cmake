string(TIMESTAMP ts "%Y-%m-%d" UTC)
cmake_path(APPEND upload_root ${GEMINI_SIMROOT} upload-${ts})
file(MAKE_DIRECTORY ${upload_root})

set(ARC_TYPE zstd)


function(gemini_package GEMINI_SIMROOT name label)

cmake_path(APPEND archive ${upload_root} ${name}.${ARC_TYPE})
cmake_path(APPEND data_dir ${GEMINI_SIMROOT} ${name})

add_test(NAME "package:${name}"
  COMMAND ${CMAKE_COMMAND} -Din:PATH=${data_dir} -Dout:FILEPATH=${archive} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/zip.cmake)

set_tests_properties("package:${name}" PROPERTIES
  FIXTURES_REQUIRED ${name}:package_fxt
  LABELS "package;${label}"
  REQUIRED_FILES "${data_dir}/inputs/config.nml;${data_dir}/output.nml"
  TIMEOUT 120)

endfunction(gemini_package)
