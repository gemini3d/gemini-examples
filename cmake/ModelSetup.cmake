function(model_setup in_dir out_dir name label)

parse_nml(${in_dir}/config.nml "eq_dir" "path")

set(eq_name)
if(eq_dir)
  get_filename_component(eq_name ${eq_dir} NAME)
endif()

if(py_ok)

  add_test(NAME "setup:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${out_dir}
    WORKING_DIRECTORY ${in_dir})

  set_tests_properties("setup:python:${name}" PROPERTIES
    LABELS "setup;python;${label}"
    FIXTURES_SETUP ${name}:run_fxt
    TIMEOUT 900)

  if(eq_name)
    set_tests_properties("setup:python:${name}" PROPERTIES FIXTURES_REQUIRED "${eq_name}:run_fxt;${name}:eq_fxt")
  else()
    set_tests_properties("setup:python:${name}" PROPERTIES FIXTURES_REQUIRED "${name}:eq_fxt")
  endif()

elseif(MATGEMINI_DIR)

  add_matlab_test("setup:matlab:${name}" "addpath('${in_dir}'); gemini3d.model.setup('${in_dir}', '${out_dir}')")

  set_tests_properties("setup:matlab:${name}" PROPERTIES
    LABELS "setup;matlab;${label}"
    FIXTURES_SETUP ${name}:run_fxt
    TIMEOUT 900)

  if(eq_name)
    set_tests_properties("setup:matlab:${name}" PROPERTIES FIXTURES_REQUIRED "${eq_name}:run_fxt;${name}:eq_fxt")
  else()
    set_tests_properties("setup:matlab:${name}" PROPERTIES FIXTURES_REQUIRED "${name}:eq_fxt")
  endif()


endif()

endfunction(model_setup)
