set(ARC_TYPE zstd)

function(download_archive url archive)

message(STATUS "download ${archive}")
file(DOWNLOAD ${url} ${archive} TLS_VERIFY ON)

endfunction(download_archive)


function(download_ref name ref_root)

# sanity check to avoid making mess
if(NOT IS_DIRECTORY ${ref_root})
  message(FATAL_ERROR "must provide 'ref_root' e.g. ~/simulations/ref_data")
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/gemini3d_url.json _refj)


string(JSON url GET ${_refj} ${name} url)
# optional checksum
string(JSON md5 ERROR_VARIABLE e GET ${_refj} ${name} md5)

set(archive_name test${name}.${ARC_TYPE})
set(ref_dir ${refroot}/test${name})
set(archive ${refroot}/${archive_name})

# check if extracted data exists and is up to date
if(EXISTS ${ref_dir}/md5sum.txt AND md5)
  file(STRINGS ${ref_dir}/md5sum.txt _md5 REGEX "[a-f0-9]" LIMIT_INPUT 32 LENGTH_MAXIMUM 32 LIMIT_COUNT 1)

  if(_md5 STREQUAL ${md5})
    return()
  endif()
elseif(IS_DIRECTORY ${ref_dir})
  # missing md5, do trivial check
  return()
endif()

# check if archive up to date
if(NOT EXISTS ${archive})
  download_archive(${url} ${archive})
endif()

file(MD5 ${archive} _md5)
if(NOT _md5 STREQUAL ${md5})
  download_archive(${url} ${archive})
endif()

message(STATUS "extract ref data to ${ref_dir}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${refroot})

file(MD5 ${archive} _md5)
file(WRITE ${ref_dir}/md5sum.txt ${_md5})

endfunction(download_ref)


download_ref(${testname})

if(DEFINED outdir)
  # copy sim inputs into build/testname/inputs
  file(COPY ${refroot}/test${testname}/inputs DESTINATION ${outdir})
endif()
