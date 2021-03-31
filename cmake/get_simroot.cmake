# the directory where all simulation output dirs are under.
# Since we use one sim to drive another, and we don't want to
# erase long runs
if(NOT GEMINI_SIMROOT AND DEFINED ENV{GEMINI_SIMROOT})
  set(GEMINI_SIMROOT $ENV{GEMINI_SIMROOT})
endif()

if(NOT GEMINI_SIMROOT)
  foreach(d ~/simulations ~/sims)
    get_filename_component(d ${d} ABSOLUTE)
    if(IS_DIRECTORY ${d})
      set(GEMINI_SIMROOT ${d})
      break()
    endif()
  endforeach()
endif()

if(NOT GEMINI_SIMROOT)
  set(GEMINI_SIMROOT ~/sims)
endif()

get_filename_component(GEMINI_SIMROOT ${GEMINI_SIMROOT} ABSOLUTE)

cmake_path(APPEND ref_root ${GEMINI_SIMROOT} test_ref)

if(NOT IS_DIRECTORY ${GEMINI_SIMROOT})
  file(MAKE_DIRECTORY ${GEMINI_SIMROOT})
endif()

if(NOT IS_DIRECTORY ${ref_root})
  file(MAKE_DIRECTORY ${ref_root})
endif()
