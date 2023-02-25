include_guard()

include(nautilus_policy)

# flag

if(CMAKE_BUILD_TYPE STREQUAL "")
  set(CMAKE_BUILD_TYPE "Release"
    CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug"
    "Release" # default
    "MinSizeRel"
    "RelWithDebInfo"
    )
endif()

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
  )

set(NAUTILUS_USE_CACHE ""
  CACHE STRING "Use a specific cache, e.g. `ccache'")
set_property(CACHE NAUTILUS_USE_LINKER PROPERTY STRINGS
  "" # default None
  "ccache"
  )

set(NAUTILUS_USE_PACKMAN ""
  CACHE STRING "What package manager is used?")
set_property(CACHE NAUTILUS_USE_PACKMAN PROPERTY STRINGS
  "" # default None
  "conan"
  # "vcpkg"
  )

# option

option(NAUTILUS_WARNINGS_AS_ERRORS "Warnings as errors?" OFF)

option(NAUTILUS_BUILD_SHARED "Build shared libraries." OFF)

option(NAUTILUS_BUILD_TESTS "Build tests?" OFF)

option(NAUTILUS_BUILD_TOOLS "Build tools?" ON)

option(NAUTILUS_ENABLE_IPO "Enable interprocedual optimization." OFF)

option(NAUTILUS_ENABLE_PCH "Enable precompile headers." OFF)

option(NAUTILUS_ENABLE_LINT "Use code check by clang tidy." ON)

option(NAUTILUS_ENABLE_COVERAGE "Use code coverage." OFF)

option(NAUTILUS_ENABLE_DOXYGEN "Generate documentation with doxygen." OFF)

# Set off means to use the default way to link.
option(NAUTILUS_LINK_STATIC "Statically link 3rdpatry libraries." OFF)

# definition

# learn more about platform at https://github.com/Kitware/CMake/blob/master/Modules/CMakePlatformId.h.in

if(MSVC)
  set(NAUTILUS_COMPILER_IS_MSVC ON CACHE BOOL "Compiler is MSVC" FORCE)
elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  set(NAUTILUS_COMPILER_IS_GCC ON CACHE BOOL "Compiler is GNU CC / CXX" FORCE)
elseif(CMAKE_C_COMPILER_ID MATCHES ".*Clang" OR
    CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  set(NAUTILUS_COMPILER_IS_CLANG ON CACHE BOOL "Compiler is Clang" FORCE)
endif()

if(NAUTILUS_WARNINGS_AS_ERRORS)
  set(NAUTILUS_MESSAGE_WARNING FATAL_ERROR)
else()
  set(NAUTILUS_MESSAGE_WARNING WARNING)
endif()

if(CMAKE_BUILD_TYPE MATCHES "Debug")
  set(NAUTILUS_BUILD_DEBUG ON CACHE BOOL "Build type is Debug" FORCE)
else()
  set(NAUTILUS_BUILD_RELEASE ON CACHE BOOL "Build type is Release" FORCE)
endif()

# override

if(NAUTILUS_BUILD_RELEASE)
  set(NAUTILUS_USE_SANITIZER "" CACHE STRING "Disable sanitizers override by build release." FORCE)
  set(NAUTILUS_ENABLE_IPO ON CACHE BOOL "Enable IPO override by build release." FORCE)
  set(NAUTILUS_ENABLE_PCH ON CACHE BOOL "Enable PCH override by build release." FORCE)
  set(NAUTILUS_ENABLE_LINT OFF CACHE BOOL "Disable code check override by build release." FORCE)
  set(NAUTILUS_ENABLE_COVERAGE OFF CACHE BOOL "Disable code coverage override by build release." FORCE)
endif()

if(NAUTILUS_BUILD_SHARED)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

if(NAUTILUS_USE_STDLIB AND NAUTILUS_STDLIB_INCLUDEDIRS STREQUAL "")
  message(FATAL_ERROR "Must specify header directory of stdlib if don't use default stdlib")
elseif(NOT NAUTILUS_USE_STDLIB)
  set(NAUTILUS_STDLIB_INCLUDEDIRS "" CACHE STRING "Don't specify header dir when use default stdlib." FORCE)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
  set(NAUTILUS_USE_SANITIZER "" CACHE STRING "Disable sanitizers when project is submodule." FORCE)
  set(NAUTILUS_BUILD_TESTS OFF CACHE BOOL "Build tests override when project is submodule." FORCE)
  set(NAUTILUS_BUILD_TOOLS OFF CACHE BOOL "Build tools override when project is submodule." FORCE)
  set(NAUTILUS_ENABLE_COVERAGE OFF CACHE BOOL "Build coverage override when project is submodule." FORCE)
  set(NAUTILUS_ENABLE_LINT OFF CACHE BOOL "Disable code check override when project is submodule." FORCE)
elseif(NAUTILUS_BUILD_TESTS)
  set(NAUTILUS_BUILD_TOOLS ON CACHE BOOL "Build tools override by NAUTILUS_BUILD_TESTS." FORCE)
  if(NAUTILUS_BUILD_RELEASE)
    set(NAUTILUS_ENABLE_COVERAGE OFF CACHE BOOL "Build coverage override by NAUTILUS_BUILD_TESTS." FORCE)
  else()
    set(NAUTILUS_ENABLE_COVERAGE ON CACHE BOOL "Build coverage override by NAUTILUS_BUILD_TESTS." FORCE)
  endif()
elseif(NAUTILUS_ENABLE_COVERAGE) # Not build tests, disable coverage
  set(NAUTILUS_ENABLE_COVERAGE OFF CACHE BOOL "Disable code coverage override by NAUTILUS_BUILD_TESTS." FORCE)
endif()
