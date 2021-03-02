# This project assumes an "installed" Gemini3D that is a particular
# version and/or Git tag that we wish to use as a milestone.

cmake_minimum_required(VERSION 3.19...3.20)

project(GeminiCI LANGUAGES NONE
HOMEPAGE_URL https://github.com/gemini3d/gemini-examples
DESCRIPTION "Long-running Gemini3D test cases"
VERSION 0.1.0)

include(CTest)

include(cmake/options.cmake)
include(cmake/libraries.cmake)

include(cmake/get_simroot.cmake)

set(ci_root ${CMAKE_CURRENT_SOURCE_DIR}/ci)

include(cmake/find_gemini.cmake)

# --- PyGemini
if(python AND NOT DEFINED py_ok)
  include(cmake/python.cmake)
endif()

# --- MatGemini
if(matlab)
  include(cmake/matlab.cmake)
endif()

# --- discover tests
set(hourly_root ${ci_root}/hourly)
file(GLOB hourly_dirs LIST_DIRECTORIES true "${hourly_root}/*")

set(daily_root ${ci_root}/daily)
file(GLOB daily_dirs LIST_DIRECTORIES true "${daily_root}/*")

include(cmake/parse_nml.cmake)
include(cmake/download_extract.cmake)
include(cmake/get_plan_cpu.cmake)

# --- main loop

foreach(in_dir ${hourly_dirs} ${daily_dirs})

set(nml_file ${in_dir}/config.nml)

if(NOT EXISTS ${nml_file})
  continue()
endif()

parse_nml(${nml_file} "eq_dir")
if(NOT eq_dir)
  continue()
endif()

get_filename_component(name ${in_dir} NAME)
set(out_dir ${sim_root}/${name})
get_filename_component(eq_dir ${out_dir}/${eq_dir} ABSOLUTE)

get_filename_component(_t ${in_dir} DIRECTORY)
get_filename_component(type_label ${_t} NAME)

if(NOT IS_DIRECTORY ${eq_dir})
  # add_test(NAME "setup:download:${name}"
  #   COMMAND ${CMAKE_COMMAND} -Dnml_file:FILEPATH=${nml_file} -P ${PROJECT_SOURCE_DIR}/cmake/download_extract.cmake)
  # set_tests_properties("setup:download:${name}" PROPERTIES
  #   LABELS "setup;download;${type_label}"
  #   TIMEOUT 300
  #   FIXTURES_SETUP ${name}:download_fxt)
  download_extract(${nml_file})
endif()

if(NOT EXISTS ${eq_dir}/inputs/config.nml)
  continue()
endif()

file(GLOB _out_files LIST_DIRECTORIES false "${eq_dir}/*.h5")
if(NOT _out_files)
  message(STATUS "SKIP: ${name}: ${eq_dir} present, but simulation was not yet run")
  continue()
endif()

if(NOT run_disabled)
  get_plan_cpu(${eq_dir} ${out_dir})
endif()

# setup model
if(py_ok)

  add_test(NAME "setup:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.model ${in_dir} ${out_dir}
    WORKING_DIRECTORY ${in_dir})

  set_tests_properties("setup:python:${name}" PROPERTIES
    LABELS "setup;python;${type_label}"
    FIXTURES_SETUP ${name}:run_fxt
    # FIXTURES_REQUIRED ${name}:download_fxt
    TIMEOUT 300)

elseif(MATGEMINI_DIR)

  add_matlab_test("setup:matlab:${name}" "addpath('${in_dir}'); gemini3d.model.setup('${in_dir}', '${out_dir}')")

  set_tests_properties("setup:matlab:${name}" PROPERTIES
    LABELS "setup;matlab;${type_label}"
    FIXTURES_SETUP ${name}:run_fxt
    # FIXTURES_REQUIRED ${name}:download_fxt
    TIMEOUT 300)

endif()

# run
add_test(NAME "run:${name}"
  COMMAND ${run_exe} ${out_dir} -n ${plan_cpu}
  WORKING_DIRECTORY ${run_parent})

set_tests_properties("run:${name}" PROPERTIES
  DISABLED $<OR:${run_disabled},$<EQUAL:0,${plan_cpu}>>
  LABELS "run;${type_label}"
  FIXTURES_REQUIRED ${name}:run_fxt
  TIMEOUT 43200
  RESOURCE_LOCK cpu_mpi
  PROCESSORS ${plan_cpu})

# plot
if(py_ok)

  add_test(NAME "plot:python:${name}"
    COMMAND ${Python_EXECUTABLE} -m gemini3d.plot ${out_dir} all)

  set_tests_properties("plot:python:${name}" PROPERTIES
    LABELS "plot;python;${type_label}"
    FIXTURES_CLEANUP ${name}:run_fxt
    TIMEOUT 600)

elseif(MATGEMINI_DIR)

  add_matlab_test("plot:matlab:${name}" "gemini3d.plot.plotall('${out_dir}', 'png')")

  set_tests_properties("plot:matlab:${name}" PROPERTIES
    LABELS "plot;matlab;${type_label}"
    FIXTURES_CLEANUP ${name}:run_fxt
    TIMEOUT 600)

endif()

endforeach()
