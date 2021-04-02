if(DEFINED ENV{CMAKE_MESSAGE_LOG_LEVEL})
  set(CMAKE_MESSAGE_LOG_LEVEL $ENV{CMAKE_MESSAGE_LOG_LEVEL})
endif()


function(download_eq eq_dir name)

cmake_path(GET eq_dir FILENAME eq_name)

file(READ ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/reference_url.json _refj)
string(JSON url GET ${_refj} ${eq_name} url)
string(JSON archive_name GET ${_refj} ${eq_name} archive)
# optional checksum
string(JSON md5 ERROR_VARIABLE e GET ${_refj} ${eq_name} md5)

cmake_path(GET eq_dir PARENT_PATH eq_root)
cmake_path(APPEND archive ${eq_root} ${archive_name})

# check if extracted data exists
if(IS_DIRECTORY ${eq_dir})
  if(md5 AND EXISTS ${eq_dir}/md5sum.txt)
    file(READ ${eq_dir}/md5sum.txt extracted_md5)
    if(${extracted_md5} STREQUAL ${md5})
      message(VERBOSE "${name}: ${eq_name} extracted md5 == JSON md5, no need to download.")
      return()
    else()
      message(STATUS "${name}: ${eq_name} extracted md5 ${extracted_md5} != JSON md5 ${md5}")
    endif()
  else()
    message(VERBOSE "${name}: ${eq_name} md5 not given  and ${eq_dir} exists, no need to download.")
    return()
  endif()
endif()

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

message(STATUS "${name}:EXTRACT: ${archive} => ${eq_dir}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${eq_dir})

# to compare extracted contents and auto-update ref data
file(MD5 ${archive} archive_md5)
file(WRITE ${eq_dir}/md5sum.txt ${archive_md5})

endfunction(download_eq)


download_eq(${eq_dir} ${name})
