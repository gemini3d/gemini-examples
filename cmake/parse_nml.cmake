# need this here to keep modern syntax handling
cmake_minimum_required(VERSION 3.19...${CMAKE_VERSION})

function(parse_nml nml_file var type)
# get variable from Fortran namelist .nml file
# only looks for variable name, assumes unique variable names

set(pre "${var}[ ]*=[ ]*")

if(type STREQUAL "path")
  set(pat1 "${pre}\'?\"?([@~/:\.\?\&=A-Za-z0-9_]+)")
  set(pat2 "${pre}\'?\"?([@~/:\.\?\&=A-Za-z0-9_]+)\'?\"?")
elseif(type STREQUAL "array")
  set(pat1 "${pre}([0-9]+),([0-9]+),([0-9]+)")
  set(pat2 ${pat1})
elseif(type STREQUAL "number")
  set(pat1 "${pre}([0-9]+)")
  set(pat2 ${pat1})
else()
  message(FATAL_ERROR "unknown NML type ${type}")
endif()

file(STRINGS ${nml_file} m REGEX ${pat1} LIMIT_COUNT 1)
if(NOT m)
  message(VERBOSE "${var} type ${type} not found in ${nml_file}")
  set(${var} PARENT_SCOPE)
  return()
endif()

string(REGEX MATCH ${pat2} n ${m})
# file(STRINGS REGEX) doesn't populate CMAKE_MATCH_*

set(v ${CMAKE_MATCH_1})
if(type STREQUAL path)
  string(CONFIGURE ${v} v @ONLY)
endif()

set(${var} ${v} PARENT_SCOPE)

endfunction(parse_nml)
