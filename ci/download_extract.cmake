function(download_extract file)

parse_nml(${file} "eq_url")
if(NOT eq_url)
  message(WARNING "${file} does not define eq_url, and ${eq_dir} is not a directory.")
  return()
endif()

parse_nml(${file} "eq_zip")
if(NOT eq_zip)
  get_filename_component(eq_zip ${eq_dir} NAME)
  set(eq_zip ${eq_zip}.zip)
endif()
get_filename_component(eq_zip ${eq_zip} ABSOLUTE)

if(NOT EXISTS ${eq_zip})
  message(STATUS "${eq_url} => ${eq_zip}")
  file(DOWNLOAD ${eq_url} ${eq_zip})
endif()

message(STATUS "${eq_zip} => ${eq_dir}")
file(ARCHIVE_EXTRACT INPUT ${eq_zip} DESTINATION ${eq_dir})

endfunction(download_extract)
