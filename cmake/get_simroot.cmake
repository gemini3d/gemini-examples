# the directory where all simulation output dirs are under.
# Since we use one sim to drive another, and we don't want to
# erase long runs
if(NOT sim_root AND DEFINED ENV{GEMINI_SIMROOT})
  set(sim_root $ENV{GEMINI_SIMROOT})
endif()

if(NOT sim_root)
  foreach(d "~/simulations" "~/sims")
    get_filename_component(d ${d} ABSOLUTE)
    if(IS_DIRECTORY ${d})
      set(sim_root ${d})
      break()
    endif()
  endforeach()
endif()

if(NOT sim_root)
  set(sim_root "${d}")
endif()

set(ref_root ${sim_root}/test_ref)

if(NOT IS_DIRECTORY ${sim_root})
  file(MAKE_DIRECTORY ${sim_root})
endif()

if(NOT IS_DIRECTORY ${ref_root})
  file(MAKE_DIRECTORY ${ref_root})
endif()

message(STATUS "using simulation root directory ${sim_root}")
