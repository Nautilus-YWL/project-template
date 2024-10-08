include_guard()

if(NOT NAUTILUS_COMPILER_LAUNCHER)
  return()
endif()

function(nautilus_enable_launcher TARGET_NAME)
  if(NOT NAUTILUS_COMPILER_LAUNCHER STREQUAL "ccache")
    return()
  endif()

  find_program(CCACHE_EXE ccache)
  if(NOT CCACHE_EXE)
    message(${NAUTILUS_MESSAGE_WARNING} "ccache requested but executable not found.")
    return()
  endif()

  set_target_properties(${TARGET_NAME} PROPERTIES C_COMPILER_LAUNCHER "${CCACHE_EXE}")
  set_target_properties(${TARGET_NAME} PROPERTIES CXX_COMPILER_LAUNCHER "${CCACHE_EXE}")
endfunction()
