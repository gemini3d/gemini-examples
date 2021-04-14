function(gemini_plot out_dir name label)

if(py_ok)

  add_test(NAME "plot:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.plot ${out_dir} all)

  set_tests_properties("plot:python:${name}" PROPERTIES
    LABELS "plot;python;${label}"
    FIXTURES_REQUIRED ${name}:run_fxt
    FIXTURES_SETUP ${name}:package_fxt
    TIMEOUT 7200
    REQUIRED_FILES "${out_dir}/inputs/config.nml;${out_dir}/output.nml"
    ENVIRONMENT GEMINI_SIMROOT=${GEMINI_SIMROOT})

  if(low_ram)
    set_tests_properties("plot:python:${name}" PROPERTIES RESOURCE_LOCK cpu_mpi)
  endif()

elseif(MATGEMINI_DIR)

  add_matlab_test("plot:matlab:${name}" "gemini3d.plot.plotall('${out_dir}', 'png')")

  set_tests_properties("plot:matlab:${name}" PROPERTIES
    LABELS "plot;matlab;${label}"
    FIXTURES_REQUIRED ${name}:run_fxt
    FIXTURES_SETUP ${name}:package_fxt
    TIMEOUT 7200
    REQUIRED_FILES "${out_dir}/inputs/config.nml;${out_dir}/output.nml")

  if(low_ram)
    set_tests_properties("plot:matlab:${name}" PROPERTIES RESOURCE_LOCK cpu_mpi)
  endif()

endif()

endfunction(gemini_plot)
