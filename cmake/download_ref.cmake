function(download_ref name ref_root)

# sanity check to avoid making mess
if(NOT IS_DIRECTORY ${ref_root})
  message(FATAL_ERROR "must provide 'ref_root' e.g. ~/simulations/ref_data")
endif()

file(READ ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/reference_url.json _refj)
string(JSON url GET ${_refj} ${name} url)
string(JSON archive_name GET ${_refj} ${name} archive)
# optional checksum
string(JSON md5 ERROR_VARIABLE e GET ${_refj} ${name} md5)

set(ref_dir ${ref_root}/${name})
set(archive ${ref_root}/${archive_name})

# check if extracted data exists
if(IS_DIRECTORY ${ref_dir})
  return()
endif()

# check if archive available
if(NOT EXISTS ${archive})
  message(STATUS "DOWNLOAD: ${url} => ${archive}")
  file(DOWNLOAD ${url} ${archive} TLS_VERIFY ON)
endif()


message(STATUS "EXTRACT: ${archive} => ${ref_dir}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${ref_dir})

file(MD5 ${archive} _md5)
file(WRITE ${ref_dir}/md5sum.txt ${_md5})

endfunction(download_ref)


download_ref(${name} ${ref_root})
