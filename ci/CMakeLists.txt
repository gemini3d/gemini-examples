# This project assumes an "installed" Gemini3D that is a particular
# version and/or Git tag that we wish to use as a milestone.

cmake_minimum_required(VERSION 3.18...3.20)

project(GeminiCI LANGUAGES NONE
HOMEPAGE_URL https://github.com/gemini3d/gemini-examples
DESCRIPTION "Long-running Gemini3D test cases"
VERSION 0.1.0)

include(CTest)

find_program(run_exe
  NAMES gemini3d.run
  HINTS ${GEMINI_ROOT} ENV GEMINI_ROOT
  PATH_SUFFIXES build bin)

if(NOT run_exe)
  message(FATAL_ERROR "Please specify the top-level install path of gemini3d.run like
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
    set(py_ok false)
    message(WARNING "PyGemini is not setup: https://github.com/gemini3d/pygemini")
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
  set(_nml ${in_dir}/config.nml)

  if(NOT EXISTS ${_nml})
    continue()
  endif()

  parse_nml(${_nml} "eq_dir")
  if(NOT eq_dir)
    continue()
  endif()
  get_filename_component(eq_dir ${eq_dir} ABSOLUTE)

  if(NOT IS_DIRECTORY ${eq_dir})
    download_extract(${_nml})
  endif()

  message(STATUS "setup ${name} using eq_dir ${eq_dir}")

  # setup model
  if(py_ok)
    add_test(NAME "setup:python:${name}"
      COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${PROJECT_BINARY_DIR}/${name}
      WORKING_DIRECTORY ${in_dir})
  endif()

  if(Matlab_FOUND)
    add_test(NAME "setup:matlab:${name}"
      COMMAND ${Matlab_MAIN_PROGRAM} -batch "gemini3d.model.setup('${in_dir}', '${PROJECT_BINARY_DIR}/${name}')"
      WORKING_DIRECTORY ${in_dir})
  endif()

endforeach()
