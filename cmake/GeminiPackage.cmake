string(TIMESTAMP ts "%Y-%m-%d" UTC)
cmake_path(APPEND upload_root ${GEMINI_SIMROOT} upload-${ts})
file(MAKE_DIRECTORY ${upload_root})

set(ARC_TYPE zstd)


function(gemini_package GEMINI_SIMROOT out_dir name label)

cmake_path(APPEND archive ${upload_root} ${name}.${ARC_TYPE})
cmake_path(APPEND data_dir ${GEMINI_SIMROOT} ${name})

add_test(NAME "package:archive:${name}"
  COMMAND ${CMAKE_COMMAND} -Din:PATH=${data_dir} -Dout:FILEPATH=${archive} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/archive.cmake)

set_tests_properties("package:archive:${name}" PROPERTIES
  FIXTURES_REQUIRED ${name}:package_fxt
  FIXTURES_SETUP ${name}:upload_fxt
  LABELS "package;${label}"
  REQUIRED_FILES "${data_dir}/inputs/config.nml;${data_dir}/output.nml"
  TIMEOUT 120)

find_program(rclone NAMES rclone)

if(rclone)

add_test(NAME "package:upload:${name}"
  COMMAND ${CMAKE_COMMAND} -Darchive:FILEPATH=${archive} -Dout_dir:PATH=${out_dir} -Dname=${name} -Dupload_root:PATH=gemini_upload-${ts} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/upload.cmake)

set_tests_properties("package:upload:${name}" PROPERTIES
  FIXTURES_REQUIRED ${name}:upload_fxt
  LABELS "package;${label}"
  REQUIRED_FILES ${archive}
  TIMEOUT 3600)
  # takes a long time to upload many small files

endif(rclone)

endfunction(gemini_package)
