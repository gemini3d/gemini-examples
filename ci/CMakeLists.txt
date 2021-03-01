# This project assumes an "installed" Gemini3D that is a particular
# version and/or Git tag that we wish to use as a milestone.

cmake_minimum_required(VERSION 3.13...3.20)

project(GeminiCI LANGUAGES NONE
HOMEPAGE_URL https://github.com/gemini3d/gemini-examples
DESCRIPTION "Long-running Gemini3D test cases"
VERSION 0.1.0)

include(CTest)

find_program(run_exe
  NAMES gemini3d.run
  HINTS ${GEMINI_ROOT} ENV GEMINI_ROOT
  PATHS ${PROJECT_SOURCE_DIR}/../../gemini3d
  PATH_SUFFIXES build bin
  DOC "Gemini3d.run Fortran front-end")

if(run_exe)
  set(run_disabled false)
  get_filename_component(run_parent ${run_exe} DIRECTORY)  # for MSIS 2.0 and similar
else()
  set(run_disabled true)
  message(WARNING "Please specify the top-level install path of gemini3d.run like
    cmake -DGEMINI_ROOT=~/code/gemini3d -B build
or specify in environment variable GEMINI_ROOT")
endif()

message(VERBOSE "gemini3d.run FOUND: ${run_exe}")

# --- get PyGemini
find_package(Python COMPONENTS Interpreter)

if(NOT DEFINED py_ok)
  execute_process(COMMAND ${Python_EXECUTABLE} -c "import gemini3d.model"
    RESULT_VARIABLE e)
  if(e EQUAL 0)
    set(py_ok true CACHE BOOL "PyGemini detected.")
  else()
    message(FATAL_ERROR "PyGemini is not setup: https://github.com/gemini3d/pygemini")
  endif()
endif()

# --- get MatGemini
# find_package(Matlab COMPONENTS MAIN_PROGRAM)

# --- discover tests

file(GLOB names LIST_DIRECTORIES true RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*")

include(parse_nml.cmake)
include(download_extract.cmake)

foreach(name ${names})

set(in_dir ${CMAKE_CURRENT_SOURCE_DIR}/${name})
set(out_dir ${PROJECT_BINARY_DIR}/${name})
set(nml_file ${in_dir}/config.nml)

if(NOT EXISTS ${nml_file})
  continue()
endif()

parse_nml(${nml_file} "eq_dir")
if(NOT eq_dir)
  continue()
endif()
get_filename_component(eq_dir ${eq_dir} ABSOLUTE)

if(NOT IS_DIRECTORY ${eq_dir})
  # add_test(NAME "setup:download:${name}"
  #   COMMAND ${CMAKE_COMMAND} -Dnml_file:FILEPATH=${nml_file} -P ${CMAKE_CURRENT_SOURCE_DIR}/download_extract.cmake)
  # set_tests_properties("setup:download:${name}" PROPERTIES
  #   TIMEOUT 300
  #   FIXTURES_SETUP download_fxt)
  download_extract(${nml_file})
endif()

set(plan_cpu 1)
if(NOT run_disabled)
  execute_process(COMMAND ${run_exe} ${out_dir} -plan
    OUTPUT_VARIABLE plan_out
    ERROR_VARIABLE plan_err
    RESULT_VARIABLE _err
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_err EQUAL 0)
    string(REGEX MATCH "MPI images: ([0-9]+)" m ${plan_out})
    if(m)
      set(plan_cpu ${CMAKE_MATCH_1})
    endif()
  else()
    message(WARNING "gemini3d.run: ${name} plan failed, disabling: ${plan_err}")
    set(run_disabled true)
  endif()
endif()

# setup model
if(py_ok)

add_test(NAME "setup:python:${name}"
  COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${out_dir}
  WORKING_DIRECTORY ${in_dir})
set_tests_properties("setup:python:${name}" PROPERTIES
  FIXTURES_SETUP run_fxt
  # FIXTURES_REQUIRED download_fxt
  TIMEOUT 300)

endif(py_ok)

if(Matlab_FOUND)

add_test(NAME "setup:matlab:${name}"
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "gemini3d.model.setup('${in_dir}', '${out_dir}')"
  WORKING_DIRECTORY ${in_dir})
set_tests_properties("setup:matlab:${name}" PROPERTIES
  FIXTURES_SETUP run_fxt
  # FIXTURES_REQUIRED download_fxt
  TIMEOUT 300)

endif(Matlab_FOUND)

# run
add_test(NAME "run:${name}"
  COMMAND ${run_exe} ${out_dir}
  WORKING_DIRECTORY ${run_parent})
set_tests_properties("run:${name}" PROPERTIES
  DISABLED ${run_disabled}
  FIXTURES_REQUIRED run_fxt
  TIMEOUT 43200
  PROCESSORS ${plan_cpu}
  RESOURCE_LOCK cpu_mpi)

# plot
if(py_ok)

add_test(NAME "plot:python:${name}"
  COMMAND ${Python_EXECUTABLE} -m gemini3d.plot ${out_dir} all)
set_tests_properties("plot:python:${name}" PROPERTIES
  FIXTURES_CLEANUP run_fxt
  TIMEOUT 600)
endif(py_ok)

if(Matlab_FOUND)

add_test(NAME "plot:matlab:${name}"
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "gemini3d.plot.plotall('${out_dir}', 'png')")
set_tests_properties("plot:matlab:${name}" PROPERTIES
  FIXTURES_CLEANUP run_fxt
  TIMEOUT 600)

endif(Matlab_FOUND)

endforeach()
