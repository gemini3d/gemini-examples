option(python "use Python for tests" on)
option(matlab "use Matlab (slower than Python)")

option(dev "dev mode" on)

option(compare "compare Gemini output" on)
option(package "package reference data .zstd files")

if(NOT DEFINED low_ram)
  cmake_host_system_information(RESULT ram QUERY TOTAL_PHYSICAL_MEMORY)
  set(low_ram false)
  if(ram LESS 18000)
    # 18 GB: the 3D Matlab plots use 9GB RAM each
    set(low_ram true)
  endif()
endif()

if(dev)
  set(FETCHCONTENT_SOURCE_DIR_PYGEMINI ${PROJECT_SOURCE_DIR}/../pygemini CACHE PATH "PyGemini developer path")
  set(FETCHCONTENT_SOURCE_DIR_MATGEMINI ${PROJECT_SOURCE_DIR}/../mat_gemini CACHE PATH "MatGemini developer path")
else()
  set(FETCHCONTENT_UPDATES_DISCONNECTED_MATGEMINI true)
  set(FETCHCONTENT_UPDATES_DISCONNECTED_PYGEMINI true)
endif()

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()
