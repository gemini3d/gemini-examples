if(DEFINED ENV{CMAKE_MESSAGE_LOG_LEVEL})
  set(CMAKE_MESSAGE_LOG_LEVEL $ENV{CMAKE_MESSAGE_LOG_LEVEL})
endif()


function(download_input input_dir name)

string(REGEX REPLACE "[\\/]+$" "" input_dir "${input_dir}") # must strip trailing slash for cmake_path(... FILENAME) to work
cmake_path(GET input_dir FILENAME input_name)
if(NOT input_name)
  message(FATAL_ERROR "${name}: ${input_dir} seems malformed, could not get directory name ${input_name}")
endif()

file(READ ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/reference_url.json _refj)
string(JSON url GET ${_refj} ${input_name} url)
string(JSON archive_name GET ${_refj} ${input_name} archive)
# optional checksum
string(JSON md5 ERROR_VARIABLE e GET ${_refj} ${input_name} md5)

cmake_path(GET input_dir PARENT_PATH input_root)
cmake_path(APPEND archive ${input_root} ${archive_name})

# check if extracted data exists
if(IS_DIRECTORY ${input_dir})
  if(md5 AND EXISTS ${input_dir}/md5sum.txt)
    file(READ ${input_dir}/md5sum.txt extracted_md5)
    if(${extracted_md5} STREQUAL ${md5})
      message(VERBOSE "${name}: ${input_name} extracted md5 == JSON md5, no need to download.")
      return()
    else()
      message(STATUS "${name}: ${input_name} extracted md5 ${extracted_md5} != JSON md5 ${md5}")
    endif()
  else()
    message(VERBOSE "${name}: ${input_name} md5 not given  and ${input_dir} exists, no need to download.")
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

message(STATUS "${name}:EXTRACT: ${archive} => ${input_dir}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${input_dir})

# to compare extracted contents and auto-update ref data
file(MD5 ${archive} archive_md5)
file(WRITE ${input_dir}/md5sum.txt ${archive_md5})

endfunction(download_input)


download_input(${input_dir} ${name})
