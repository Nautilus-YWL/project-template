include_guard()

include(nautilus_check)
include(nautilus_definition)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/configuration")

include(nautilus_compiler)
include(nautilus_generator)
include(nautilus_linker)
include(nautilus_precompile_header)

list(REMOVE_AT CMAKE_MODULE_PATH -1)
