function(gemini_run run_exe out_dir name label)

get_filename_component(run_parent ${run_exe} DIRECTORY)
# for MSIS 2.0 and similar

set(run_cmd ${run_exe} ${out_dir} -mpiexec ${MPIEXEC_EXECUTABLE})

add_test(NAME "run:${name}"
  COMMAND ${run_cmd}
  WORKING_DIRECTORY ${run_parent})

set_tests_properties("run:${name}" PROPERTIES
  DISABLED $<NOT:$<BOOL:${run_exe}>>
  LABELS "run;${label}"
  FIXTURES_SETUP ${name}:run_fxt
  FIXTURES_REQUIRED ${name}:setup_fxt
  TIMEOUT 43200
  RESOURCE_LOCK cpu_mpi
  ENVIRONMENT GEMINI_SIMROOT=${GEMINI_SIMROOT})

endfunction(gemini_run)
