function(make_archive in out)

get_filename_component(in ${in} ABSOLUTE)
get_filename_component(out ${out} ABSOLUTE)

file(ARCHIVE_CREATE
  OUTPUT ${out}
  PATHS ${in}
  COMPRESSION Zstd
  COMPRESSION_LEVEL 3)

# ensure a file was created (weak validation)
if(NOT EXISTS ${out})
  message(FATAL_ERROR "Archive ${out} was not created.")
endif()

file(SIZE ${out} fsize)
if(fsize LESS 1000)
  message(FATAL_ERROR "Archive ${out} may be malformed.")
endif()

endfunction(make_archive)

make_archive(${in} ${out})
