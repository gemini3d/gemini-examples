function(model_setup in_dir out_dir name label)

if(py_ok)

  add_test(NAME "setup:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${out_dir}
    WORKING_DIRECTORY ${in_dir})

  set_tests_properties("setup:python:${name}" PROPERTIES
    LABELS "setup;python;${label}"
    FIXTURES_SETUP ${name}:setup_fxt
    TIMEOUT 900
    ENVIRONMENT GEMINI_SIMROOT=${GEMINI_SIMROOT})

  set_tests_properties("setup:python:${name}" PROPERTIES FIXTURES_REQUIRED "${name}:eq_fxt")

elseif(MATGEMINI_DIR)

  add_matlab_test("setup:matlab:${name}" "addpath('${in_dir}'); gemini3d.model.setup('${in_dir}', '${out_dir}')")

  set_tests_properties("setup:matlab:${name}" PROPERTIES
    LABELS "setup;matlab;${label}"
    FIXTURES_SETUP ${name}:setup_fxt
    TIMEOUT 900
    ENVIRONMENT GEMINI_SIMROOT=${GEMINI_SIMROOT})

  set_tests_properties("setup:matlab:${name}" PROPERTIES FIXTURES_REQUIRED "${name}:eq_fxt")

endif()

endfunction(model_setup)
