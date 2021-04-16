function(plot_archive in out)

if(NOT IS_DIRECTORY ${in})
  message(STATUS "${in} does not exist, simulation must have matched expected data.")
  return()
endif()

cmake_path(GET out EXTENSION LAST_ONLY ARC_TYPE)

if(ARC_TYPE STREQUAL .zst OR ARC_TYPE STREQUAL .zstd)
  # to avoid relative path issues:
  # 1. working_directory ${in}
  # 2. . instead of ${in} as last argument
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar c ${out} --zstd .
    WORKING_DIRECTORY ${in})

elseif(ARC_TYPE STREQUAL .zip)

  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar c ${out} --format=zip .
    WORKING_DIRECTORY ${in})

else()
  message(FATAL_ERROR "unknown archive type ${ARC_TYPE}")
endif()

# ensure an archive file was created (weak validation)
if(NOT EXISTS ${out})
  message(FATAL_ERROR "Archive ${out} was not created.")
endif()

file(SIZE ${out} fsize)
if(fsize LESS 10000)
  message(FATAL_ERROR "Archive ${out} may be malformed.")
endif()

endfunction(plot_archive)


plot_archive(${in} ${out})
