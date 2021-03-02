function(parse_nml nml_file var)
# get alphanumeric variable such as a file path from Fortran namelist .nml file

file(STRINGS "${nml_file}" m REGEX "${var}[ ]*=[ ]*\'?\"?([~/:\.\?\&=A-Za-z0-9_]+)" LIMIT_COUNT 1)
if(NOT m)
  set(${var} PARENT_SCOPE)
  return()
endif()

string(REGEX MATCH "${var}[ ]*=[ ]*\'?\"?([~/:\.\?\&=A-Za-z0-9_]+)\'?\"?" n ${m})
set(${var} ${CMAKE_MATCH_1} PARENT_SCOPE)

endfunction(parse_nml)
