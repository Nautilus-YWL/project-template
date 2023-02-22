include_guard()

include(nautilus_option)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/tool")

include(nautilus_lint)
include(nautilus_cache)
if(NAUTILUS_ENABLE_DOXYGEN)
  include(nautilus_doxygen)
endif()
