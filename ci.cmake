cmake_minimum_required(VERSION 3.19...3.20)

set(CTEST_PROJECT_NAME "Gemini3Dproject")
set(CTEST_NIGHTLY_START_TIME "01:00:00 UTC")
set(CTEST_MODEL "Experimental")
set(CTEST_GROUP "GeminiProjectCI")
set(CTEST_SUBMIT_URL "https://my.cdash.org/submit.php?project=${CTEST_PROJECT_NAME}")

set(CTEST_LABELS_FOR_SUBPROJECTS "python;matlab")

# --- boilerplate follows
set(CTEST_TEST_TIMEOUT 10)
set(CTEST_OUTPUT_ON_FAILURE true)

set(CTEST_SOURCE_DIRECTORY ${CTEST_SCRIPT_DIRECTORY})
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  set(CTEST_BINARY_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/build)
endif()

if(NOT DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION "Release")
endif()

if(NOT DEFINED CTEST_SITE)
  if(DEFINED ENV{CTEST_SITE})
    set(CTEST_SITE $ENV{CTEST_SITE})
  else()
    cmake_host_system_information(RESULT sys_name QUERY OS_NAME OS_RELEASE OS_VERSION)
    string(REPLACE ";" " " sys_name ${sys_name})
    set(CTEST_SITE ${sys_name})
  endif()
endif()

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
    if(run_exe)
      execute_process(COMMAND ${run_exe} -compiler_version
        OUTPUT_VARIABLE _compiler_version OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _err
        TIMEOUT 5)
      if(_err EQUAL 0)
        execute_process(COMMAND ${run_exe} -git
          OUTPUT_VARIABLE _git_version OUTPUT_STRIP_TRAILING_WHITESPACE
          RESULT_VARIABLE _err
          TIMEOUT 5)
      endif()
      if(_err EQUAL 0)
        set(CTEST_BUILD_NAME "${_compiler_version}  ${_git_version}")
      endif()
    endif(run_exe)
  endif()
endif()

# for subproject labels
set(CTEST_USE_LAUNCHERS 1)
set(ENV{CTEST_USE_LAUNCHERS_DEFAULT} 1)

# CTEST_CMAKE_GENERATOR must always be defined
if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  find_program(ninja NAMES ninja ninja-build samu)
  if(ninja)
    execute_process(COMMAND ${ninja} --version
      OUTPUT_VARIABLE ninja_version
      OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE err
      TIMEOUT 10)
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

# --- test parallelism is used for setup and plotting
include(ProcessorCount)

function(cmake_cpu_count)
  # on ARM e.g. Raspberry Pi, the usually reliable cmake_host_system_info gives 1 instead of true count
  # fallback to less reliable ProcessorCount which does work on Raspberry Pi.
  ProcessorCount(_ncount)
  cmake_host_system_information(RESULT Ncpu QUERY NUMBER_OF_PHYSICAL_CORES)

  if(Ncpu EQUAL 1 AND _ncount GREATER 0)
    set(Ncpu ${_ncount})
  endif()

  set(Ncpu ${Ncpu} PARENT_SCOPE)

endfunction(cmake_cpu_count)
cmake_cpu_count()

# setup/plotting can use a lot of RAM for big sims
cmake_host_system_information(RESULT ram QUERY TOTAL_PHYSICAL_MEMORY)
if(ram LESS 16000 AND Ncpu GREATER 2)
  message(STATUS "set max parallel tests to 2 due to RAM < 16 GB.")
  set(Ncpu 2)
elseif(ram LESS 32000 AND Ncpu GREATER 4)
  message(STATUS "set max parallel tests to 4 due to RAM < 32 GB.")
  set(Ncpu 4)
endif()

# --- CTest Dashboard

set(CTEST_NOTES_FILES "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")
set(CTEST_SUBMIT_RETRY_COUNT 3)

ctest_start(${CTEST_MODEL} GROUP ${CTEST_GROUP})
# ctest_submit(PARTS Notes)

ctest_configure(
  RETURN_VALUE _ret
  CAPTURE_CMAKE_ERROR _err)
ctest_submit(PARTS Configure)
if(NOT (_ret EQUAL 0 AND _err EQUAL 0))
  message(FATAL_ERROR "Configure failed.")
endif()

# there is no ctest_build as we're testing already built external packages

ctest_test(PARALLEL_LEVEL ${Ncpu})
ctest_submit(PARTS Test)

ctest_submit(PARTS Done)
