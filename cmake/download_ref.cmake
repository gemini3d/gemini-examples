if(DEFINED ENV{CMAKE_MESSAGE_LOG_LEVEL})
  set(CMAKE_MESSAGE_LOG_LEVEL $ENV{CMAKE_MESSAGE_LOG_LEVEL})
endif()

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
  if(md5 AND EXISTS ${ref_dir}/md5sum.txt)
    file(READ ${ref_dir}/md5sum.txt extracted_md5)
    if(${extracted_md5} STREQUAL ${md5})
      message(VERBOSE "${name}: extracted md5 == JSON md5, no need to download.")
      return()
    else()
      message(STATUS "${name}: extracted md5 ${extracted_md5} != JSON md5 ${md5}")
    endif()
  else()
    message(VERBOSE "${name}: JSON md5 not given and ${ref_dir} exists, no need to download.")
    return()
  endif()
endif()

# check if archive available
set(hash_ok true)
if(EXISTS ${archive} AND DEFINED md5)
  file(MD5 ${archive} archive_md5)
  if(${archive_md5} STREQUAL ${md5})
    message(VERBOSE "${name}: archive md5 == JSON md5, no need to download.")
  else()
    message(STATUS "${name}: archive md5 ${archive_md5} != JSON md5 ${md5}")
    set(hash_ok false)
  endif()
endif()

if(NOT EXISTS ${archive} OR NOT hash_ok)
  message(STATUS "${name}:DOWNLOAD: ${url} => ${archive}   ${md5}")
  if(md5)
    file(DOWNLOAD ${url} ${archive} TLS_VERIFY ON EXPECTED_HASH MD5=${md5})
  else()
    file(DOWNLOAD ${url} ${archive} TLS_VERIFY ON)
  endif()
endif()


message(STATUS "${name}:EXTRACT: ${archive} => ${ref_dir}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${ref_dir})

# to compare extracted contents and auto-update ref data
file(MD5 ${archive} archive_md5)
file(WRITE ${ref_dir}/md5sum.txt ${archive_md5})

endfunction(download_ref)


download_ref(${name} ${ref_root})
