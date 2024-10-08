include_guard()

include(nautilus_policy)

# flag

set(NAUTILUS_STDLIB_INCLUDEDIRS ""
  CACHE STRING "Specify header directories of stdlib, must be specify if not use default")
# e.g.
#   stdcxx: /usr/include/c++/7;/usr/include/x86_64-linux-gnu/c++/7
#   cxx: /usr/lib/llvm-15/include/c++/v1

set(NAUTILUS_USE_SANITIZER ""
  CACHE STRING "Build with sanitizers, e.g. `Address;Undefined'.")

set(NAUTILUS_USE_STDLIB ""
  CACHE STRING "Use std library of C++.")
set_property(CACHE NAUTILUS_USE_STDLIB PROPERTY STRINGS
  ""
  "stdcxx"
  "cxx"
  )

set(NAUTILUS_USE_LINKER ""
  CACHE STRING "Use a specific linker, e.g. `bfd'")
set_property(CACHE NAUTILUS_USE_LINKER PROPERTY STRINGS
  "" # default is bfd
  "bfd"
  "gold"
  "lld"
  "mold"
  )

set(NAUTILUS_COMPILER_LAUNCHER ""
  CACHE STRING "A compiler launching tool, e.g. `ccache'")
set_property(CACHE NAUTILUS_COMPILER_LAUNCHER PROPERTY STRINGS
  "" # default None
  "ccache"
  )

set(NAUTILUS_USE_COVERAGE ""
  CACHE STRING "Use a specific coverage, e.g. `gcovr'")
set_property(CACHE NAUTILUS_USE_COVERAGE PROPERTY STRINGS
  "" # default None
  "gcovr"
  "lcov"
  )

# option

option(NAUTILUS_WARNINGS_AS_ERRORS "Warnings as errors?" OFF)

option(NAUTILUS_BUILD_32BITS "Build 32 bits executables and libraries." OFF)

option(NAUTILUS_BUILD_SHARED "Build shared libraries." OFF)

option(NAUTILUS_BUILD_TESTS "Build tests?" OFF)

option(NAUTILUS_BUILD_TOOLS "Build tools?" ON)

option(NAUTILUS_ENABLE_IPO "Enable interprocedual optimization." OFF)

option(NAUTILUS_ENABLE_PCH "Enable precompile headers." OFF)

option(NAUTILUS_ENABLE_LINT "Use code check by clang tidy." OFF)

option(NAUTILUS_ENABLE_DOXYGEN "Generate documentation with doxygen." OFF)

# Set off means to use the default way to link.
option(NAUTILUS_LINK_STATIC "Statically link 3rdpatry libraries." OFF)
