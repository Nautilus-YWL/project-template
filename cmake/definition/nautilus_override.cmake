include_guard()

include(nautilus_defvar)
include(nautilus_option)

if(NAUTILUS_ARCH_IS_32BIT)
  set(NAUTILUS_TARGET_IS_64BIT OFF)
  set(NAUTILUS_TARGET_IS_32BIT ON)
endif()

if(NAUTILUS_BUILD_SHARED)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

if(NAUTILUS_USE_STDLIB AND NOT NAUTILUS_COMPILER_IS_CLANG AND
    NAUTILUS_STDLIB_INCLUDEDIRS STREQUAL "")
  message(FATAL_ERROR "Must specify header directory of stdlib if don't use default stdlib")
elseif(NOT NAUTILUS_USE_STDLIB)
  set(NAUTILUS_STDLIB_INCLUDEDIRS "" CACHE STRING "Don't specify header dir when use default stdlib." FORCE)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
  set(NAUTILUS_USE_SANITIZER "" CACHE STRING "Disable sanitizers when project is submodule." FORCE)
  set(NAUTILUS_BUILD_TESTS OFF CACHE BOOL "Build tests override when project is submodule." FORCE)
  set(NAUTILUS_BUILD_TOOLS OFF CACHE BOOL "Build tools override when project is submodule." FORCE)
  set(NAUTILUS_USE_COVERAGE "" CACHE STRING "Build coverage override when project is submodule." FORCE)
  set(NAUTILUS_ENABLE_LINT OFF CACHE BOOL "Disable code check override when project is submodule." FORCE)
elseif(NAUTILUS_BUILD_TESTS)
  set(NAUTILUS_BUILD_TOOLS ON CACHE BOOL "Build tools override by NAUTILUS_BUILD_TESTS." FORCE)
elseif(NAUTILUS_USE_COVERAGE) # Not build tests, disable coverage
  set(NAUTILUS_USE_COVERAGE "" CACHE STRING "Disable code coverage override by NAUTILUS_BUILD_TESTS." FORCE)
endif()
