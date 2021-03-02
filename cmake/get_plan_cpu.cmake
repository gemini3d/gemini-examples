function(get_plan_cpu plan_dir out_dir)

# gemini3d.run -plan needs these files to do the planning
foreach(f ${plan_dir}/inputs/config.nml ${plan_dir}/inputs/simsize.h5)
  if(NOT EXISTS ${out_dir}/inputs/${f})
    file(COPY ${f} DESTINATION ${out_dir}/inputs/)
  endif()
endforeach()

execute_process(COMMAND ${run_exe} ${out_dir} -plan
  OUTPUT_VARIABLE plan_out
  ERROR_VARIABLE plan_err
  RESULT_VARIABLE _err
  OUTPUT_STRIP_TRAILING_WHITESPACE)
if(_err EQUAL 0)
  string(REGEX MATCH "MPI images: ([0-9]+)" m ${plan_out})
  if(m)
    set(Ncpu ${CMAKE_MATCH_1})
  endif()
else()
  message(WARNING "gemini3d.run: ${name} plan failed, disabling: ${plan_err}")
  set(plan_cpu 0 PARENT_SCOPE)
  return()
endif()

cmake_host_system_information(RESULT sys_info QUERY OS_NAME OS_PLATFORM)
if(sys_info STREQUAL "macOS;arm64")
  # Apple Silicon M1 workaround for hwloc et al:
  # https://github.com/open-mpi/hwloc/issues/454
  cmake_host_system_information(RESULT Nhybrid QUERY NUMBER_OF_PHYSICAL_CORES)

  math(EXPR N "${Nhybrid} / 2")  # use only fast cores, else MPI tests very slow
  if(N GREATER Ncpu)
    set(N ${Ncpu})
  endif()

  while(N GREATER 2)
    math(EXPR R "${Ncpu} % ${N}")
    if(R EQUAL 0)
      break()
    endif()
    math(EXPR N "${N} - 1")
  endwhile()

  set(Ncpu ${N})
endif()

set(plan_cpu ${Ncpu} PARENT_SCOPE)


endfunction(get_plan_cpu)
