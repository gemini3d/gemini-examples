# --- find gemini frontend
find_program(GEMINI_RUN
  NAMES gemini3d.run
  HINTS ${GEMINI_ROOT} ENV GEMINI_ROOT
  PATHS ${PROJECT_SOURCE_DIR}/../gemini3d
  PATH_SUFFIXES build bin
  DOC "Gemini3d.run Fortran front-end")


# --- find gemini.compare
find_program(GEMINI_COMPARE
  NAMES gemini3d.compare
  HINTS ${GEMINI_ROOT} ENV GEMINI_ROOT
  PATHS ${PROJECT_SOURCE_DIR}/../gemini3d
  PATH_SUFFIXES build bin
  DOC "Gemini3d.compare Fortran comparison")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Gemini3D
  REQUIRED_VARS GEMINI_RUN GEMINI_COMPARE)
