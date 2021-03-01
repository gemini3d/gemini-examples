set(CTEST_OUTPUT_ON_FAILURE true)

set(CTEST_SOURCE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  set(CTEST_BINARY_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/build)
endif()

if(NOT DEFINED CTEST_SITE)
  if(DEFINED ENV{CTEST_SITE})
    set(CTEST_SITE $ENV{CTEST_SITE})
  else()
    cmake_host_system_information(RESULT sys_name QUERY OS_NAME OS_VERSION)
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
      PATHS ${PROJECT_SOURCE_DIR}/../../gemini3d
      PATH_SUFFIXES build bin
      DOC "Gemini3d.run Fortran front-end")
    if(run_exe)
      execute_process(COMMAND ${run_exe} -compiler_version
        OUTPUT_VARIABLE _compiler_version
        RESULT_VARIABLE _err
        TIMEOUT 5
        OUTPUT_STRIP_TRAILING_WHITESPACE)
      if(_err EQUAL 0)
        execute_process(COMMAND ${run_exe} -git
          OUTPUT_VARIABLE _git_version
          RESULT_VARIABLE _err
          TIMEOUT 5
          OUTPUT_STRIP_TRAILING_WHITESPACE)
      endif()
      if(_err EQUAL 0)
        set(CTEST_BUILD_NAME "${_compiler_version}  ${_git_version}")
      endif()
    endif(run_exe)
  endif()
endif()

# --- CTEST_CMAKE_GENERATOR
# must always be defined, despite not building here
if(NOT DEFINED CTEST_CMAKE_GENERATOR)
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

# -- CTest Dashboard
ctest_start("Experimental" ${CTEST_SOURCE_DIRECTORY} ${CTEST_BINARY_DIRECTORY})

ctest_configure(
  RETURN_VALUE _ret
  CAPTURE_CMAKE_ERROR _err)
if(NOT (_ret EQUAL 0 AND _err EQUAL 0))
  message(SEND_ERROR "Configure failed.")
endif()

# there is no ctest_build as we're testing already built external packages

ctest_test(
  PARALLEL_LEVEL ${Ncpu}
  RETURN_VALUE _ret
  CAPTURE_CMAKE_ERROR _err)
if(NOT (_ret EQUAL 0 AND _err EQUAL 0))
  message(SEND_ERROR "Test failed.")
endif()

ctest_submit()
