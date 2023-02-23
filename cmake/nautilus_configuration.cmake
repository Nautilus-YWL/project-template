include_guard()

include(nautilus_option)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")  # static link library files
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")  # dynamic link library files
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")  # excutable files

set(NAUTILUS_COMPILE_DEFINITIONS_COMMON)
set(NAUTILUS_COMPILE_DEFINITIONS_DEVELOP)
set(NAUTILUS_COMPILE_DEFINITIONS_RELEASE)
set(NAUTILUS_COMPILE_OPTIONS_COMMON)
set(NAUTILUS_COMPILE_OPTIONS_DEVELOP)
set(NAUTILUS_COMPILE_OPTIONS_RELEASE)
set(NAUTILUS_LINK_OPTIONS_COMMON)
set(NAUTILUS_LINK_OPTIONS_DEVELOP)
set(NAUTILUS_LINK_OPTIONS_RELEASE)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/configuration")

include(nautilus_compiler)
include(nautilus_generator)
include(nautilus_linker)
include(nautilus_precompile_header)
if(NAUTILUS_USE_SANITIZER)
  include(nautilus_sanitizer)
endif()

list(REMOVE_AT CMAKE_MODULE_PATH -1)
