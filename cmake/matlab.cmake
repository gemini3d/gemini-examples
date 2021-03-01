include(FetchContent)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)

FetchContent_Declare(MATGEMINI
  GIT_REPOSITORY ${matgemini_git}
  GIT_TAG ${matgemini_tag})

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.14)
  FetchContent_MakeAvailable(MATGEMINI)
elseif(NOT matgemini_POPULATED)
  FetchContent_Populate(MATGEMINI)
endif()


if(NOT MATGEMINI_DIR)
  execute_process(COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${matgemini_SOURCE_DIR}/setup.m'), gemini3d.fileio.expanduser('~');"
    RESULT_VARIABLE _ok
    TIMEOUT 90)

  if(_ok EQUAL 0)
    message(STATUS "MatGemini found: ${matgemini_SOURCE_DIR}")
    set(MATGEMINI_DIR ${matgemini_SOURCE_DIR} CACHE PATH "MatGemini path")
  endif()
endif()


function(add_matlab_test testname cmd)

add_test(NAME ${testname}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${CMAKE_CURRENT_LIST_DIR}/../setup.m'); ${cmd}"
  WORKING_DIRECTORY ${matgemini_SOURCE_DIR})

endfunction(add_matlab_test)
