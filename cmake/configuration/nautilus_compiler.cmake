include_guard()

macro(_NAUTILUS_COMPILER_CONFIG_MSVC)
  list(APPEND NAUTILUS_COMPILE_DEFINITIONS_COMMON
    _CRT_NONSTDC_NO_DEPRECATE
    _CRT_SECURE_NO_DEPRECATE
    _CRT_SECURE_NO_WARNINGS
    _SCL_SECURE_NO_WARNINGS
    NOMINMAX # disable min/max problem in windows.h
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    /bigobj # Compiler Fatal error C1128: Object Limit Exceed
    /Oi # enable built-in functions
    /permissive-
    /source-charset:utf-8
    /volatile:iso # Specifies how the volatile keyword is to be interpreted.
    /wd4996 # mark deprecated (/W3)
    $<$<AND:$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>,$<VERSION_GREATER:MSVC_VERSION,1900>>:/WX>
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
    /Wall
    )
  if(CXX IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      /GR- # Disable RTTI
      )
  endif()
endmacro()

macro(_NAUTILUS_COMPILER_CONFIG_GCC)
  # GNU Compiler Collection
  # Learn more at https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    -fmax-errors=5
    -finput-charset=UTF8
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
    -fprofile-abs-path
    # --coverage is equivalent to -ftest-profile -fprofile-arcs
    $<$<NOT:$<BOOL:$<STREQUAL:${NAUTILUS_USE_COVERAGE},"">>>:--coverage>
    )
  if(CXX IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -fno-threadsafe-statics
      -fmerge-all-constants
      $<$<NOT:$<STREQUAL:${NAUTILUS_USE_STDLIB},>>:-nostdinc++>
      )
  endif()
  foreach(dir IN LISTS NAUTILUS_STDLIB_INCLUDEDIRS)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON -isystem${dir})
  endforeach()
endmacro()

macro(_NAUTILUS_COMPILER_CONFIG_CLANG)
  # Clang
  # Learn more at https://clang.llvm.org/docs/UsersManual.html
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    -ferror-limit=5
    -finput-charset=UTF-8
    )
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
    -fdiagnostics-absolute-paths
    # --coverage is equivalent to -ftest-profile -fprofile-arcs
    $<$<NOT:$<BOOL:$<STREQUAL:${NAUTILUS_USE_COVERAGE},"">>>:
      $<IF:$<BOOL:$<STREQUAL:${NAUTILUS_USE_COVERAGE},"gcovr">>,
        --coverage,
        -fprofile-instr-generate\;-fcoverage-mapping>>
    )
  if(CXX IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -Wthread-safety
      $<$<BOOL:$<STREQUAL:${NAUTILUS_USE_STDLIB},cxx>>:-stdlib=libc++>
      )
  endif()
endmacro()

get_property(NAUTILUS_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NAUTILUS_COMPILER_IS_MSVC)
  _NAUTILUS_COMPILER_CONFIG_MSVC()
else()
  list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
    -fno-common
    $<$<BOOL:${NAUTILUS_WARNINGS_AS_ERRORS}>:-Werror\;-Wno-error=deprecated-declarations>
    )
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
    # from kDE cmake
    -Wcast-align
    -Wno-long-long
    )
  if(CXX IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -fno-rtti # Disable RTTI
      )
  endif()
  if(NAUTILUS_COMPILER_IS_GCC)
    _NAUTILUS_COMPILER_CONFIG_GCC()
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    _NAUTILUS_COMPILER_CONFIG_CLANG()
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "Unknow compiler ${CMAKE_CXX_COMPILER_ID}.")
  endif()
endif()
unset(NAUTILUS_LANGUAGES)
