# This project assumes an "installed" Gemini3D that is a particular
# version and/or Git tag that we wish to use as a milestone.

cmake_minimum_required(VERSION 3.19...3.20)

project(GeminiCI LANGUAGES NONE
HOMEPAGE_URL https://github.com/gemini3d/gemini-examples
DESCRIPTION "Long-running Gemini3D test cases"
VERSION 0.1.0)

include(CTest)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

include(cmake/options.cmake)
include(cmake/libraries.cmake)

include(cmake/get_simroot.cmake)
include(cmake/parse_nml.cmake)

find_package(Gemini3D REQUIRED)

# helper functions
include(cmake/EquilSetup.cmake)
include(cmake/ModelSetup.cmake)
include(cmake/GeminiRun.cmake)
include(cmake/GeminiCompare.cmake)
include(cmake/GeminiPlot.cmake)
include(cmake/GeminiPackage.cmake)

set(ci_root ${CMAKE_CURRENT_SOURCE_DIR}/ci)



# --- PyGemini
if(python AND NOT DEFINED py_ok)
  include(cmake/python.cmake)
endif()

# --- MatGemini
if(matlab)
  include(cmake/matlab.cmake)
endif()

# --- discover tests

file(GLOB equilibrium_dirs LIST_DIRECTORIES true "${ci_root}/equilibrium/*")
file(GLOB hourly_dirs LIST_DIRECTORIES true "${ci_root}/hourly/*")
file(GLOB daily_dirs LIST_DIRECTORIES true "${ci_root}/daily/*")

# --- main loop

foreach(in_dir ${hourly_dirs} ${daily_dirs} ${equilibrium_dirs})

if(CMAKE_VERSION VERSION_LESS 3.20)
  get_filename_component(_t ${in_dir} DIRECTORY)
  get_filename_component(type_label ${_t} NAME)
  get_filename_component(name ${in_dir} NAME)
else()
  cmake_path(GET in_dir PARENT_PATH _t)
  cmake_path(GET _t STEM type_label)
  cmake_path(GET in_dir FILENAME name)
endif()

set(out_dir ${sim_root}/${name})

# equilibrium (creation or download)
equil_setup(${in_dir} "${equilibrium_dirs}" ${out_dir})

# setup model
model_setup()

# --- run
gemini_run(${GEMINI_RUN} ${out_dir} ${name} ${type_label})

# --- compare
if(compare)
  gemini_compare(${GEMINI_COMPARE} ${out_dir} ${ref_root} ${name} ${type_label})
endif(compare)

# --- plot
gemini_plot(${out_dir} ${name} ${type_label})

# --- package upload
gemini_package(${sim_root} ${out_dir} ${name} ${type_label})

endforeach()

# ---
include(FeatureSummary)

add_feature_info(compare compare "compare gemini3d output")

feature_summary(WHAT ALL)
