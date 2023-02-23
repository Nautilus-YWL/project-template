include_guard()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NAUTILUS_COMPILER_IS_MSVC)
  list(APPEND NAUTILUS_COMPILE_DEFINITIONS_COMMON
    _CRT_SECURE_NO_WARNINGS
    _SCL_SECURE_NO_WARNINGS
    NOMINMAX # disable min/max problem in windows.h
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    /bigobj # Compiler Fatal error C1128: Object Limit Exceed
    /permissive-
    /source-charset:utf-8
    /volatile:iso # Specifies how the volatile keyword is to be interpreted.
    /wd4996 # mark deprecated (/W3)
    $<$<COMPILE_LANGUAGE:CXX>:/GR-> # Disable RTTI
    $<$<AND:$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>,$<VERSION_GREATER:MSVC_VERSION,1900>>:/WX>
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
    /Wall
    )
else()
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    -fno-common
    -fno-stack-protector
    $<$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>:-Werror>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti> # Disable RTTI
    $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<STREQUAL:${NAUTILUS_USE_STDLIB},>>>:-nostdinc++>
    )
  foreach(dir IN LISTS NAUTILUS_STDLIB_INCLUDEDIRS)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON -isystem${dir})
  endforeach()
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
    -Wall
    -fno-inline
    -pedantic
    # from lua Makefile, enable compiler warning
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
  list(APPEND NAUTILUS_COMPILE_OPTION_RELEASE
    -march=native
    )
  if(NAUTILUS_COMPILER_IS_GCC)
    # GNU Compiler Collection
    # Learn more at https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -fmax-errors=5
      -finput-charset=UTF8
      $<$<COMPILE_LANGUAGE:CXX>:-fno-threadsafe-statics\;-fmerge-all-constants>
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-arcs\;-ftest-coverage>
      )
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    # Clang
    # Learn more at https://clang.llvm.org/docs/UsersManual.html
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -ferror-limit=5
      -finput-charset=UTF-8
      $<$<COMPILE_LANGUAGE:CXX>:-Wthread-safety>
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-instr-generate\;-fcoverage-mapping>
      )
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "Unknow compiler ${CMAKE_CXX_COMPILER_ID}.")
  endif()
endif()
