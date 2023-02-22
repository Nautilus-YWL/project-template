cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

project(nautilus
  LANGUAGES CXX
  VERSION 0.1)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(nautilus_configuration)
include(nautilus_option)
include(nautilus_policy)
include(nautilus_tools)

add_subdirectory(src)
add_subdirectory(test)
