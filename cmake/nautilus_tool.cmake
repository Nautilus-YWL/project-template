include_guard()

include(nautilus_check)
include(nautilus_definition)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/tool")

include(nautilus_coverage)
if(NAUTILUS_ENABLE_DOXYGEN)
  include(nautilus_doxygen)
endif()
include(nautilus_launcher)
include(nautilus_lint)
include(nautilus_sanitizer)

list(REMOVE_AT CMAKE_MODULE_PATH -1)
