cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

project(nautilus
  LANGUAGES CXX
  VERSION 0.1)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

add_subdirectory(src)
add_subdirectory(test)
