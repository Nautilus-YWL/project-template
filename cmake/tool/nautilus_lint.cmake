include_guard()

function(nautilus_enable_clang_tidy)
  if(NOT NAUTILUS_ENABLE_LINT)
    return()
  endif()

  find_program(CLANG_TIDY_EXE clang-tidy)
  if(NOT CLANG_TIDY_EXE)
    message(${NAUTILUS_MESSAGE_WARNING} "clang-tidy requested but executable not found.")
    return()
  endif()

  set(lint_command ${CLANG_TIDY_EXE} -header-filter=.*)
  if(NAUTILUS_WARNINGS_AS_ERRORS)
    list(APPEND lint_command -warnings-as-errors=*)
  endif()
  set(CMAKE_C_CLANG_TIDY   ${lint_command}
    CACHE FILEPATH "C compiler clang-tidy used" FORCE)
  set(CMAKE_CXX_CLANG_TIDY ${lint_command}
    CACHE FILEPATH "CXX compiler clang-tidy used" FORCE)
endfunction()

function(nautilus_enable_iwyu)
  if(NOT NAUTILUS_ENABLE_LINT)
    return()
  endif()

  find_program(INCLUDE_WHAT_YOU_USE_EXE include-what-you-use)
  if(NOT INCLUDE_WHAT_YOU_USE_EXE)
    message(${NAUTILUS_MESSAGE_WARNING} "include-what-you-use requested but executable not found.")
    return()
  endif()

  set(CMAKE_C_INCLUDE_WHAT_YOU_USE   ${INCLUDE_WHAT_YOU_USE_EXE}
    CACHE FILEPATH "C compiler include-what-you-use used" FORCE)
  set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE_EXE}
    CACHE FILEPATH "C compiler include-what-you-use used" FORCE)
endfunction()
