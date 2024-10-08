cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

project(nautilus
  LANGUAGES CXX
  VERSION 0.1)

if(CMAKE_VERSION VERSION_LESS 3.21)
  get_property(not_top DIRECTORY PROPERTY PARENT_DIRECTORY)
  if(NOT not_top)
    set(PROJECT_IS_TOP_LEVEL ON)
  endif()
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(nautilus_configuration)
include(nautilus_definition)
include(nautilus_tool)

list(REMOVE_AT CMAKE_MODULE_PATH -1)

add_subdirectory(src)

enable_testing()
if(NAUTILUS_BUILD_TESTS)
  add_subdirectory(test)
endif()
