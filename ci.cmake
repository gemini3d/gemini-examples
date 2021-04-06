cmake_minimum_required(VERSION 3.19...${CMAKE_VERSION})

set(CTEST_PROJECT_NAME "Gemini3Dproject")

set(CTEST_LABELS_FOR_SUBPROJECTS "python;matlab")

set(opts -Dmatlab:BOOL=yes -Dpython:BOOL=no)

# --- boilerplate follows

set(CI false)
if(DEFINED ENV{CI})
  set(CI $ENV{CI})
endif()

set(CTEST_NIGHTLY_START_TIME "01:00:00 UTC")
set(CTEST_SUBMIT_URL "https://my.cdash.org/submit.php?project=${CTEST_PROJECT_NAME}")

# ctest -S doesn't have a way to pass -Dvar:type=value, so do this via env var
# cannot pass in lists--use CMakePresets.json for list variables. Example:
# ctest --preset=my1 -S setup.cmake
list(APPEND opts $ENV{CTEST_${CTEST_PROJECT_NAME}_ARGS})

# --- Experimental, Nightly, Continuous
# https://cmake.org/cmake/help/latest/manual/ctest.1.html#dashboard-client-modes
if(NOT CTEST_MODEL AND DEFINED ENV{CTEST_MODEL})
  set(CTEST_MODEL $ENV{CTEST_MODEL})
endif()
if(NOT CTEST_MODEL AND CI)
  set(CTEST_MODEL "Nightly")
endif()
if(NOT CTEST_MODEL)
  set(CTEST_MODEL "Experimental")
endif()

# --- other defaults
set(CTEST_TEST_TIMEOUT 10)
set(CTEST_OUTPUT_ON_FAILURE true)

set(CTEST_SOURCE_DIRECTORY ${CTEST_SCRIPT_DIRECTORY})
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  set(CTEST_BINARY_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/build)
endif()

if(CTEST_MODEL STREQUAL Nightly OR CTEST_MODEL STREQUAL Continuous)
  if(EXISTS ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt)
    ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  endif()
endif()

if(NOT CMAKE_BUILD_TYPE)
  # RelWithDebInfo -O2, Release -O3
  set(CMAKE_BUILD_TYPE Release)
endif()
list(APPEND opts -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})

if(NOT DEFINED CTEST_SITE)
  if(DEFINED ENV{CTEST_SITE})
    set(CTEST_SITE $ENV{CTEST_SITE})
  else()
    cmake_host_system_information(RESULT sys_name QUERY OS_NAME OS_RELEASE OS_VERSION)
    string(REPLACE ";" " " sys_name ${sys_name})
    set(CTEST_SITE ${sys_name})
  endif()
endif()

find_program(GIT_EXECUTABLE NAMES git REQUIRED)

if(NOT DEFINED CTEST_BUILD_NAME)
  if(DEFINED ENV{CTEST_BUILD_NAME})
    set(CTEST_BUILD_NAME $ENV{CTEST_BUILD_NAME})
  else()
    find_program(run_exe
      NAMES gemini3d.run
      HINTS ${GEMINI_ROOT} ENV GEMINI_ROOT
      PATHS ${CTEST_SOURCE_DIRECTORY}/../gemini3d
      PATH_SUFFIXES build bin
      DOC "Gemini3d.run Fortran front-end"
      REQUIRED)

    # execute_process(COMMAND ${run_exe} -compiler_version
    #   OUTPUT_VARIABLE _compiler_version OUTPUT_STRIP_TRAILING_WHITESPACE
    #   RESULT_VARIABLE _err
    #   TIMEOUT 5
    #   COMMAND_ERROR_IS_FATAL ANY)

    execute_process(COMMAND ${run_exe} -git
      OUTPUT_VARIABLE _git_version OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE _err
      TIMEOUT 5
      COMMAND_ERROR_IS_FATAL ANY)

    set(CTEST_BUILD_NAME ${_git_version})
  endif()
endif()


set(CTEST_USE_LAUNCHERS 1)

# --- find generator
function(find_generator)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.17)
  find_program(ninja NAMES ninja ninja-build samu)

  if(ninja)
    execute_process(COMMAND ${ninja} --version
      OUTPUT_VARIABLE ninja_version OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE err
      TIMEOUT 5)
    if(err EQUAL 0 AND ninja_version VERSION_GREATER_EQUAL 1.10)
      set(CTEST_CMAKE_GENERATOR Ninja)
    endif()
  endif(ninja)
endif()

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  set(CTEST_BUILD_FLAGS -j)  # not --parallel as this goes to generator directly
  if(WIN32)
    set(CTEST_CMAKE_GENERATOR "MinGW Makefiles")
  else()
    set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
  endif()
endif()

set(CTEST_CMAKE_GENERATOR ${CTEST_CMAKE_GENERATOR} PARENT_SCOPE)

endfunction(find_generator)

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  if(DEFINED ENV{CMAKE_GENERATOR})
    set(CTEST_CMAKE_GENERATOR $ENV{CMAKE_GENERATOR})
  else()
    find_generator()
  endif()
endif()

# --- test parallelism
include(ProcessorCount)

function(cmake_cpu_count)
  # on ARM e.g. Raspberry Pi, the usually reliable cmake_host_system_info gives 1 instead of true count
  # fallback to less reliable ProcessorCount which does work on Raspberry Pi.

cmake_host_system_information(RESULT sys_info QUERY OS_NAME OS_PLATFORM)
if(sys_info STREQUAL "macOS;arm64")
  # Apple Silicon M1 workaround for hwloc et al:
  # https://github.com/open-mpi/hwloc/issues/454
  cmake_host_system_information(RESULT Nhybrid QUERY NUMBER_OF_PHYSICAL_CORES)

  math(EXPR Ncpu "${Nhybrid} / 2")  # use only fast cores, else MPI very slow

  message(STATUS "Apple M1 hybrid CPU count workaround applied.")
else()
  ProcessorCount(_ncount)
  cmake_host_system_information(RESULT Ncpu QUERY NUMBER_OF_PHYSICAL_CORES)

  if(Ncpu EQUAL 1 AND _ncount GREATER 0)
    set(Ncpu ${_ncount})
  endif()
endif()

# limit RAM use as Matlab/Python in parallel can use a lot of RAM with 3D grids
cmake_host_system_information(RESULT ram QUERY TOTAL_PHYSICAL_MEMORY)
set(low_ram false)
if(ram LESS 18000)
  # 18 GB: the 3D Matlab plots use 9GB RAM each
  set(low_ram true)
  if(Ncpu GREATER 2)
    set(Ncpu 2)
  endif()
endif()
list(APPEND opts -Dlow_ram:BOOL=${low_ram})

set(Ncpu ${Ncpu} PARENT_SCOPE)

endfunction(cmake_cpu_count)

cmake_cpu_count()
message(STATUS "using Ncpu = ${Ncpu}")

# --- CTest Dashboard

set(CTEST_SUBMIT_RETRY_COUNT 2)
# avoid auto-detect version control failures on some systems
set(CTEST_UPDATE_TYPE git)
set(CTEST_UPDATE_COMMAND git)

ctest_start(${CTEST_MODEL})
if(CI)
  ctest_submit(PARTS Start)
endif(CI)

if(CTEST_MODEL STREQUAL Nightly OR CTEST_MODEL STREQUAL Continuous)
  # this erases local code changes i.e. anything not "git push" already is lost forever!
  # we try to avoid that by guarding with a Git porcelain check
  execute_process(COMMAND ${GIT_EXECUTABLE} status --porcelain
    WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
    OUTPUT_VARIABLE _ret OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE _err)
  if(NOT _err EQUAL 0)
    message(FATAL_ERROR "CTest could not check Git porcelain status")
  endif()
  if(_ret)
    message(WARNING "CTest would have erased the non-Git Push'd changes, NOT updating.")
  else()
    ctest_update(RETURN_VALUE _ret)
    if(_ret EQUAL 0 AND CTEST_MODEL STREQUAL Continuous)
      message(STATUS "No Git-updated files, so no need to test in CTest Model ${CTEST_MODEL}. CTest stopping.")
      return()
    endif()
  endif()
endif()

ctest_configure(
  OPTIONS "${opts}"
  RETURN_VALUE _ret
  CAPTURE_CMAKE_ERROR _err)
if(NOT (_ret EQUAL 0 AND _err EQUAL 0))
  ctest_submit(BUILD_ID build_id)
  message(FATAL_ERROR "Configure ${build_id} failed: return ${_ret} cmake return ${_err}")
endif()

# there is no ctest_build as we're testing already built external packages

ctest_test(
  # set PARALLEL_LEVEL here as the global option seems to be ignored
  PARALLEL_LEVEL ${Ncpu}
  SCHEDULE_RANDOM ON
  RETURN_VALUE _ret
  CAPTURE_CMAKE_ERROR _err)

ctest_submit(BUILD_ID build_id)

if(NOT (_ret EQUAL 0 AND _err EQUAL 0))
  message(FATAL_ERROR "Build ${build_id} failed: CTest code ${_ret}, CMake code ${_err}.")
endif()

message(STATUS "OK: CTest build ${build_id}")
