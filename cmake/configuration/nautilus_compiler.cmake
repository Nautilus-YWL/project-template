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
    /W3
    /Wall
    /permissive-
    /source-charset:utf-8
    /volatile:iso # Specifies how the volatile keyword is to be interpreted.
    /wd4996 # Compiler Warning (level 3) C4996
    /bigobj # Compiler Fatal error C1128
    $<$<COMPILE_LANGUAGE:CXX>:/GR-> # Disable RTTI
    $<$<AND:$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>,$<VERSION_GREATER:MSVC_VERSION,1900>>:/WX>
    )
else()
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    -fno-stack-protector
    -fno-common
    -Wall
    $<$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>:-Werror>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti> # Disable RTTI
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
    -fno-inline
    -pedantic
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
  list(APPEND NAUTILUS_COMPILE_OPTION_RELEASE
    -march=native
    )
  if(NAUTILUS_COMPILER_IS_GCC)
    # GNU Compiler Collection
    # Learn more at https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -finput-charset=UTF8
      "$<$<COMPILE_LANGUAGE:CXX>:-fno-threadsafe-statics\;-fmerge-all-constants>"
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-arcs\;-ftest-coverage>
      )
    list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
      -fmax-errors=5
      )
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    # Clang
    # Learn more at https://clang.llvm.org/docs/UsersManual.html
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -finput-charset=UTF-8
      $<$<COMPILE_LANGUAGE:CXX>:-Wthread-safety>
      # $<$<BOOL:${NAUTILUS_ENABLE_COVERAGE}>:-fprofile-instr-generate\;-fcoverage-mapping>
      )
    list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
      -ferror-limit=5
      )
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "Unknow compiler ${CMAKE_CXX_COMPILER_ID}.")
  endif()
endif()
