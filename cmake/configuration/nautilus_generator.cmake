include_guard()

if(CMAKE_GENERATOR MATCHES "Ninja")
  if(NAUTILUS_COMPILER_IS_MSVC)
  elseif(NAUTILUS_COMPILER_IS_GCC)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -fdiagnostics-color=always
      )
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -fcolor-diagnostics
      )
  endif()
endif()
