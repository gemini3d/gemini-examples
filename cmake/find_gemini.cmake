# --- find gemini
find_program(run_exe
  NAMES gemini3d.run
  HINTS ${GEMINI_ROOT} ENV GEMINI_ROOT
  PATHS ${PROJECT_SOURCE_DIR}/../gemini3d
  PATH_SUFFIXES build bin
  DOC "Gemini3d.run Fortran front-end")

if(run_exe)
  set(run_disabled 0)
  get_filename_component(run_parent ${run_exe} DIRECTORY)  # for MSIS 2.0 and similar
else()
  set(run_disabled 1)
  message(WARNING "Please specify the top-level install path of gemini3d.run like
    cmake -DGEMINI_ROOT=~/code/gemini3d -B build
or specify in environment variable GEMINI_ROOT")
endif()

message(STATUS "gemini3d.run FOUND: ${run_exe}")
