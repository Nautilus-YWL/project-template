include_guard()

include(nautilus_option)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")  # static link library files
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")  # dynamic link library files
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")  # excutable files

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/configuration")

include(nautilus_compiler)
include(nautilus_generator)
include(nautilus_linker)
include(nautilus_precompile_header)
include(nautilus_sanitizer)
