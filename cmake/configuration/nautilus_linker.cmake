include_guard()

function(target_enable_ipo TARGET_NAME)
  if(NOT NAUTILUS_ENABLE_IPO)
    return()
  endif()
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if(result)
    set_target_properties(${TARGET_NAME} PROPERTIES
      INTERPROCEDURAL_OPTIMIZATION ON)
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "IPO is not supported: ${output}.")
  endif()
endfunction()

if(NAUTILUS_COMPILER_IS_MSVC)
else()
  add_link_options(
    "$<$<BOOL:${NAUTILUS_USE_LINKER}>:-fuse-ld=${NAUTILUS_USE_LINKER}>"
    )
  if(NAUTILUS_COMPILER_IS_GCC)
    add_link_options(
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-arcs\;-ftest-coverage>
      )
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    add_link_options(
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-instr-generate\;-fcoverage-mapping>
      )
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "Unknow compiler ${CMAKE_CXX_COMPILER_ID}.")
  endif()
endif()
