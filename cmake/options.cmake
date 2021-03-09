option(python "use Python for tests" off)
option(matlab "use Matlab instead of Python" on)

option(dev "dev mode" on)

option(compare "compare Gemini output")
option(package "package new reference .zip")


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
