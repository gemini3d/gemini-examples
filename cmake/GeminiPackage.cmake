function(gemini_package sim_root out_dir name label)

string(TIMESTAMP ts "%Y-%m-%d" UTC)

set(upload_root ${sim_root}/upload-${ts})

file(MAKE_DIRECTORY ${upload_root})

set(new_zip ${upload_root}/${name}.zip)

add_test(NAME "package:${name}"
  COMMAND ${CMAKE_COMMAND} -Dout_dir:PATH=${out_dir} -Dnew_zip:FILEPATH=${new_zip} -P cmake/zip.cmake)

set_tests_properties("package:${name}" PROPERTIES
  FIXTURES_REQUIRED ${name}:package_fxt
  LABELS "package;${label}")

endfunction(gemini_package)
