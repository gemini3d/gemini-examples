option(python "use Python for tests" on)
option(matlab "use Matlab instead of Python")

if(matlab)
  set(python false)
endif()



if(dev)
  set(FETCHCONTENT_SOURCE_DIR_PYGEMINI ${PROJECT_SOURCE_DIR}/../pygemini CACHE PATH "PyGemini developer path")
  set(FETCHCONTENT_SOURCE_DIR_MATGEMINI ${PROJECT_SOURCE_DIR}/../mat_gemini CACHE PATH "MatGemini developer path")
else()
  set(FETCHCONTENT_UPDATES_DISCONNECTED_MATGEMINI true)
  set(FETCHCONTENT_UPDATES_DISCONNECTED_PYGEMINI true)
endif()
