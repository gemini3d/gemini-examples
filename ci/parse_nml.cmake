function(parse_nml file var)

file(STRINGS ${file} m REGEX "${var}[ ]*=[ ]*\'?\"?([~/A-Za-z0-9_]+)" LIMIT_COUNT 1)
if(NOT m)
  set(${var} PARENT_SCOPE)
  return()
endif()

string(REGEX MATCH "${var}[ ]*=[ ]*\'?\"?([~/:\.\?\&=A-Za-z0-9_]+)\'?\"?" eq_dir ${m})
set(${var} ${CMAKE_MATCH_1} PARENT_SCOPE)

endfunction(parse_nml)
