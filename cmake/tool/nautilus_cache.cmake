include_guard()

function(nautilus_enable_ccache)
  if(NOT NAUTILUS_ENABLE_CACHE)
    return()
  endif()

  find_program(CCACHE_EXE ccache)
  if(NOT CCACHE_EXE)
    message(${NAUTILUS_MESSAGE_WARNING} "ccache requested but executable not found.")
    return()
  endif()

  set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_EXE}
    CACHE FILEPATH "C compiler cache used" FORCE)
  set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_EXE}
    CACHE FILEPATH "CXX compiler cache used" FORCE)
endfunction()
