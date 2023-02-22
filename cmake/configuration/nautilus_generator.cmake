include_guard()

if(CMAKE_GENERATOR STREQUAL "Ninja")
  if(NAUTILUS_COMPILER_IS_MSVC)
  elseif(NAUTILUS_COMPILER_IS_GCC)
    add_compile_options(
      -fdiagnostics-color=always
      )
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    add_compile_options(
      -fcolor-diagnostics
      )
  endif()
endif()
