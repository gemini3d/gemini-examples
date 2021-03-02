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

include(cmake/parse_nml.cmake)
include(cmake/download_extract.cmake)

# --- PyGemini
if(python AND NOT DEFINED py_ok)
  include(cmake/python.cmake)
endif()

# --- MatGemini
if(matlab)
  include(cmake/matlab.cmake)
endif()

# --- discover tests
if(equil)
  file(GLOB sim_dirs LIST_DIRECTORIES true "${ci_root}/equilibrium/*")
else(equil)
  file(GLOB hourly_dirs LIST_DIRECTORIES true "${ci_root}/hourly/*")
  file(GLOB daily_dirs LIST_DIRECTORIES true "${ci_root}/daily/*")
  set(sim_dirs ${hourly_dirs} ${daily_dirs})
endif(equil)

# --- MacOS ARM64 workaround

cmake_host_system_information(RESULT sys_info QUERY OS_NAME OS_PLATFORM)
if(sys_info STREQUAL "macOS;arm64")
  # Apple Silicon M1 workaround for hwloc et al:
  # https://github.com/open-mpi/hwloc/issues/454
  cmake_host_system_information(RESULT Nhybrid QUERY NUMBER_OF_PHYSICAL_CORES)

  math(EXPR plan_cpu "${Nhybrid} / 2")  # use only fast cores, else MPI very slow
endif()

# --- main loop

foreach(in_dir ${sim_dirs})

set(nml_file ${in_dir}/config.nml)

if(NOT EXISTS ${nml_file})
  continue()
endif()

if(NOT equil)
  parse_nml(${nml_file} "eq_dir")
  if(NOT eq_dir)
    continue()
  endif()
endif()

get_filename_component(_t ${in_dir} DIRECTORY)
get_filename_component(type_label ${_t} NAME)

get_filename_component(name ${in_dir} NAME)
set(out_dir ${sim_root}/${name})

if(equil)
  if(IS_DIRECTORY ${out_dir})
    message(STATUS "SKIP: ${name}: existing equilibrium ${out_dir}")
    continue()
  endif()

  set(plan_dir ${out_dir})
else(equil)
  get_filename_component(eq_dir ${out_dir}/${eq_dir} ABSOLUTE)

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

  set(plan_dir ${eq_dir})
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
set(cmd ${run_exe} ${out_dir})
if(plan_cpu)
  list(APPEND cmd -n ${plan_cpu})
endif()
add_test(NAME "run:${name}"
  COMMAND ${cmd}
  WORKING_DIRECTORY ${run_parent})

set_tests_properties("run:${name}" PROPERTIES
  DISABLED ${run_disabled}
  LABELS "run;${type_label}"
  FIXTURES_REQUIRED ${name}:run_fxt
  TIMEOUT 43200
  RESOURCE_LOCK cpu_mpi)

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
