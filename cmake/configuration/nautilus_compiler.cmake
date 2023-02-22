include_guard()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NAUTILUS_COMPILER_IS_MSVC)
  add_compile_definitions(
    _CRT_SECURE_NO_WARNINGS
    _SCL_SECURE_NO_WARNINGS
    NOMINMAX # disable min/max problem in windows.h
    )
  add_compile_options(
    /W3
    /Wall
    /source-charset:utf-8
    /volatile:iso # Specifies how the volatile keyword is to be interpreted.
    /wd4996 # Compiler Warning (level 3) C4996
    /bigobj # Compiler Fatal error C1128
    $<$<COMPILE_LANGUAGE:CXX>:/GR-> # Disable RTTI
    $<$<AND:$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>,$<VERSION_GREATER:MSVC_VERSION,1900>>:/WX>
    )
else()
  set(NAUTILUS_COMPILE_OPTIONS_DEBUG
    -fno-inline
    # from lua Makefile
    -Wdisabled-optimization
    -Wdouble-promotion
    -Wextra
    -Wmissing-declarations
    -Wredundant-decls
    -Wshadow
    -Wsign-compare
    -Wundef
    # -Wfatal-errors
    )
  add_compile_options(
    -fno-stack-protector
    -fno-common
    -Wall
    -march=native
    $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti> # Disable RTTI
    "$<$<CONFIG:DEBUG>:${NAUTILUS_COMPILE_OPTIONS_DEBUG}>"
    $<$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>:-Werror>
    )
  if(NAUTILUS_COMPILER_IS_GCC)
    # GNU Compiler Collection
    add_compile_options(
      -finput-charset=UTF8
      -Wa,-mbig-obj
      $<$<CONFIG:DEBUG>:-fmax-errors=5>
      $<$<COMPILE_LANGUAGE:CXX>:-fno-threadsafe-statics\;-fmerge-all-constants>
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-arcs\;-ftest-coverage>
      )
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    # Clang
    add_compile_options(
      -finput-charset=UTF-8
      $<$<CONFIG:DEBUG>:-ferror-limit=5>
      $<$<COMPILE_LANGUAGE:CXX>:-Wthread-safety>
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<STREQUAL:${NAUTILUS_USE_STDLIB},"cxx">>:-stdlib=libc++>
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-instr-generate\;-fcoverage-mapping>
      )
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "Unknow compiler ${CMAKE_CXX_COMPILER_ID}.")
  endif()
endif()
