function(model_setup)

if(py_ok)

  add_test(NAME "setup:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${out_dir}
    WORKING_DIRECTORY ${in_dir})

  set_tests_properties("setup:python:${name}" PROPERTIES
    LABELS "setup;python;${type_label}"
    FIXTURES_SETUP ${name}:run_fxt
    FIXTURES_REQUIRED ${name}:eq_fxt
    TIMEOUT 900)

elseif(MATGEMINI_DIR)

  add_matlab_test("setup:matlab:${name}" "addpath('${in_dir}'); gemini3d.model.setup('${in_dir}', '${out_dir}')")

  set_tests_properties("setup:matlab:${name}" PROPERTIES
    LABELS "setup;matlab;${type_label}"
    FIXTURES_SETUP ${name}:run_fxt
    FIXTURES_REQUIRED ${name}:eq_fxt
    TIMEOUT 900)

endif()

endfunction(model_setup)
