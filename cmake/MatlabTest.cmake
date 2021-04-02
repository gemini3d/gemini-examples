function(add_matlab_test name cmd)

add_test(NAME ${name}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${matgemini_SOURCE_DIR}/setup.m'); ${cmd}"
  WORKING_DIRECTORY ${matgemini_SOURCE_DIR})

endfunction(add_matlab_test)
