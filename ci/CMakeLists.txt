# This project assumes an "installed" Gemini3D that is a particular
# version and/or Git tag that we wish to use as a milestone.

cmake_minimum_required(VERSION 3.13...3.20)

project(GeminiCI LANGUAGES NONE
HOMEPAGE_URL https://github.com/gemini3d/gemini-examples
DESCRIPTION "Long-running Gemini3D test cases"
VERSION 0.1.0)

include(CTest)

include(${PROJECT_SOURCE_DIR}/../cmake/options.cmake)
include(${PROJECT_SOURCE_DIR}/../cmake/libraries.cmake)

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

if(python AND NOT DEFINED py_ok)
  execute_process(COMMAND ${Python_EXECUTABLE} -c "import gemini3d.model"
    RESULT_VARIABLE e)
  if(e EQUAL 0)
    set(py_ok true CACHE BOOL "PyGemini detected.")
  else()
    message(WARNING "PyGemini is not setup: https://github.com/gemini3d/pygemini")
  endif()
endif()

# --- get MatGemini
if(NOT py_ok)
  include(${PROJECT_SOURCE_DIR}/../cmake/matlab.cmake)
endif()

# --- discover tests

file(GLOB names LIST_DIRECTORIES true RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*")

include(${PROJECT_SOURCE_DIR}/../cmake/parse_nml.cmake)
include(${PROJECT_SOURCE_DIR}/../cmake/download_extract.cmake)

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

set(in_files ${eq_dir}/inputs/config.nml ${eq_dir}/inputs/simsize.h5)

if(NOT IS_DIRECTORY ${eq_dir})
  # add_test(NAME "setup:download:${name}"
  #   COMMAND ${CMAKE_COMMAND} -Dnml_file:FILEPATH=${nml_file} -P ${PROJECT_SOURCE_DIR}/../cmake/download_extract.cmake)
  # set_tests_properties("setup:download:${name}" PROPERTIES
  #   LABELS "setup;download"
  #   TIMEOUT 300
  #   FIXTURES_SETUP ${name}:download_fxt)
  download_extract(${nml_file})
endif()

set(plan_cpu)
if(NOT run_disabled)

  cmake_host_system_information(RESULT sys_info QUERY OS_NAME OS_PLATFORM)
  if(sys_info STREQUAL "macOS;arm64")
    # Apple Silicon M1 workaround for hwloc et al:
    # https://github.com/open-mpi/hwloc/issues/454
    cmake_host_system_information(RESULT Nhybrid QUERY NUMBER_OF_PHYSICAL_CORES)

    math(EXPR plan_cpu "${Nhybrid} / 2")  # use only fast cores, else MPI tests very slow
  else()
    # non-hybrid CPU
    file(COPY ${in_files} DESTINATION ${out_dir}/inputs/)

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
endif()

# setup model
if(py_ok)

  add_test(NAME "setup:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${out_dir}
    WORKING_DIRECTORY ${in_dir})

  set_tests_properties("setup:python:${name}" PROPERTIES
    LABELS "setup;python"
    FIXTURES_SETUP ${name}:run_fxt
    # FIXTURES_REQUIRED ${name}:download_fxt
    TIMEOUT 300)

elseif(Matlab_FOUND)

  add_matlab_test("setup:matlab:${name}" "addpath('${in_dir}'); gemini3d.model.setup('${in_dir}', '${out_dir}')")

  set_tests_properties("setup:matlab:${name}" PROPERTIES
    LABELS "setup;matlab"
    FIXTURES_SETUP ${name}:run_fxt
    # FIXTURES_REQUIRED ${name}:download_fxt
    TIMEOUT 300)

endif()

# run
add_test(NAME "run:${name}"
  COMMAND ${run_exe} ${out_dir} -n ${plan_cpu}
  WORKING_DIRECTORY ${run_parent})
set_tests_properties("run:${name}" PROPERTIES
  DISABLED ${run_disabled}
  LABELS "run"
  FIXTURES_REQUIRED ${name}:run_fxt
  TIMEOUT 43200
  PROCESSORS ${plan_cpu}
  RESOURCE_LOCK cpu_mpi)

# plot
if(py_ok)

  add_test(NAME "plot:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.plot ${out_dir} all)

  set_tests_properties("plot:python:${name}" PROPERTIES
    LABELS "plot;python"
    FIXTURES_CLEANUP ${name}:run_fxt
    TIMEOUT 600)

elseif(Matlab_FOUND)

  add_matlab_test("plot:matlab:${name}" "gemini3d.plot.plotall('${out_dir}', 'png')")

  set_tests_properties("plot:matlab:${name}" PROPERTIES
    LABELS "plot;matlab"
    FIXTURES_CLEANUP ${name}:run_fxt
    TIMEOUT 600)

endif()

endforeach()
