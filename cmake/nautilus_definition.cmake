include_guard()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/definition")

include(nautilus_defvar)
include(nautilus_option)
include(nautilus_override)
include(nautilus_policy)

list(REMOVE_AT CMAKE_MODULE_PATH -1)
