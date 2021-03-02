function(get_plan_cpu eq_dir out_dir run_disabled)

set(plan_cpu)
if(run_disabled)
  return()
endif()

set(in_files ${eq_dir}/inputs/config.nml ${eq_dir}/inputs/simsize.h5)

cmake_host_system_information(RESULT sys_info QUERY OS_NAME OS_PLATFORM)
if(sys_info STREQUAL "macOS;arm64")
  # Apple Silicon M1 workaround for hwloc et al:
  # https://github.com/open-mpi/hwloc/issues/454
  cmake_host_system_information(RESULT Nhybrid QUERY NUMBER_OF_PHYSICAL_CORES)

  math(EXPR plan_cpu "${Nhybrid} / 2")  # use only fast cores, else MPI tests very slow
else()
  # non-hybrid CPU
  file(COPY ${in_files} DESTINATION ${out_dir}/inputs/)

  execute_process(COMMAND ${run_exe} ${out_dir} -plan
    OUTPUT_VARIABLE plan_out
    ERROR_VARIABLE plan_err
    RESULT_VARIABLE _err
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_err EQUAL 0)
    string(REGEX MATCH "MPI images: ([0-9]+)" m ${plan_out})
    if(m)
      set(plan_cpu ${CMAKE_MATCH_1})
    endif()
  else()
    message(WARNING "gemini3d.run: ${name} plan failed, disabling: ${plan_err}")
    set(run_disabled true)
  endif()
endif()

set(plan_cpu ${plan_cpu} PARENT_SCOPE)
set(run_disabled ${run_disabled} PARENT_SCOPE)


endfunction(get_plan_cpu)