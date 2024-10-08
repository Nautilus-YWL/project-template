include_guard()

macro(__nautilus_coverage_parse_args PREFIX)
  set(options)
  set(oneValueArgs BASEDIR)
  set(multiValueArgs ADDITIONAL_ARGS EXCLUDES)
  cmake_parse_arguments(${PREFIX} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT ${PREFIX}_BASEDIR)
    set(${PREFIX}_BASEDIR ${PROJECT_SOURCE_DIR})
  endif()
endmacro()

function(__nautilus_coverage_get_excludes BASEDIR EXCLUDES)
  set(COV_LIST_EXCLUDES)
  foreach(EXCLUDE ${EXCLUDES})
    get_filename_component(EXCLUDE ${EXCLUDE} ABSOLUTE BASE_DIR ${BASEDIR})
    list(APPEND COV_LIST_EXCLUDES "${EXCLUDE}")
  endforeach()
  list(REMOVE_DUPLICATES COV_LIST_EXCLUDES)
  set(COV_LIST_EXCLUDES ${COV_LIST_EXCLUDES} PARENT_SCOPE)
endfunction()

macro(__nautilus_coverage_get_gcov)
  find_program(COV_FE_PATH ${NAUTILUS_USE_COVERAGE})
  if(NOT COV_FE_PATH)
    message(FATAL_ERROR "${NAUTILUS_USE_COVERAGE} not found! Aborting...")
  endif()
  if(NAUTILUS_COMPILER_IS_CLANG)
    find_program(LLVM_COV_PATH llvm-cov)
    if(LLVM_COV_PATH)
      file(GENERATE OUTPUT ${CMAKE_BINARY_DIR}/llvm-gcov
           CONTENT "#!/usr/bin/env bash\nexec ${LLVM_COV_PATH} gcov \"$@\"\n"
           FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
      set(COV_PATH ${CMAKE_BINARY_DIR}/llvm-gcov)
    endif()
  endif()
  if(NOT COV_PATH)
    find_program(GCOV_PATH gcov)
    if(NOT GCOV_PATH)
      message(FATAL_ERROR "gcov / llvm-cov not found!")
    else()
      set(COV_PATH ${GCOV_PATH})
    endif()
  endif()
endmacro()

function(__nautilus_coverage_name TARGET_NAME TOOL)
  set(NAME ${TARGET_NAME}_coverage_${TOOL})
  set(RESULT_DIR ${PROJECT_BINARY_DIR}/${NAME})
  set(REUSLT_FILE ${RESULT_DIR}/index.html)
  set(CREATE_REUSLT_DIR_CMD ${CMAKE_COMMAND} -E make_directory ${RESULT_DIR})
  set(COV_NAME ${NAME} PARENT_SCOPE)
  set(COV_RESULT_DIR ${RESULT_DIR} PARENT_SCOPE)
  set(COV_CREATE_REUSLT_DIR_CMD ${CREATE_REUSLT_DIR_CMD} PARENT_SCOPE)
endfunction()

function(nautilus_target_coverage_gcovr TARGET_NAME)
  if(NOT NAUTILUS_USE_COVERAGE OR NOT NAUTILUS_USE_COVERAGE STREQUAL "gcovr")
    return()
  endif()

  __nautilus_coverage_get_gcov()
  __nautilus_coverage_parse_args(NAUTILUS_GCOVR ${ARGN})
  __nautilus_coverage_get_excludes(${NAUTILUS_GCOVR_BASEDIR} "${NAUTILUS_GCOVR_EXCLUDES}")
  set(GCOVR_EXCLUDE_ARGS)
  foreach(EXCLUDE ${COV_LIST_EXCLUDES})
    list(APPEND GCOVR_EXCLUDE_ARGS "-e")
    list(APPEND GCOVR_EXCLUDE_ARGS "${EXCLUDE}")
  endforeach()
  __nautilus_coverage_name(${TARGET_NAME} ${NAUTILUS_USE_COVERAGE})
  get_property(TGT_WORKING_DIR TEST ${TARGET_NAME} PROPERTY WORKING_DIRECTORY)
  if(NOT TGT_WORKING_DIR)
    set(TGT_WORKING_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  set(GCOVR_CMD
    ${COV_FE_PATH} --html ${COV_RESULT_DIR}/index.html --html-details -r ${NAUTILUS_GCOVR_BASEDIR}
    ${NAUTILUS_GCOVR_ADDITIONAL_ARGS} ${GCOVR_EXCLUDE_ARGS} --object-directory=${PROJECT_BINARY_DIR}
    --gcov-executable=${COV_PATH}
  )
  add_custom_target(${COV_NAME}
    COMMAND ${COV_CREATE_REUSLT_DIR_CMD}
    COMMAND ${GCOVR_CMD}
    BYPRODUCTS ${COV_RESULT_DIR}/index.html
    WORKING_DIRECTORY ${TGT_WORKING_DIR}
    DEPENDS ${TARGET_NAME}
    VERBATIM # Protect arguments to commands
    COMMENT "Running ${NAUTILUS_USE_COVERAGE} to code coverage report."
    )
  add_test(
    NAME ${TARGET_NAME}_coverage
    CONFIGURATIONS Debug
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target ${COV_NAME}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  )
  set_tests_properties(${TARGET_NAME}_coverage PROPERTIES FIXTURES_CLEANUP ${TARGET_NAME})
endfunction()

macro(__nautilus_coverage_lcov_with_gcov)
  # the latest gcc maybe failed with lcov: https://github.com/linux-test-project/lcov/issues/296
  set(LCOV_CLEANUP_CMD ${COV_FE_PATH} --zerocounters --directory ${PROJECT_BINARY_DIR})
  set(LCOV_BASELINE_CMD
    ${COV_FE_PATH} --capture --branch-coverage --directory ${PROJECT_BINARY_DIR} --output-file ${LCOV_NAME_PREFIX}.base
    --base-directory ${NAUTILUS_LCOV_BASEDIR} --initial --gcov-tool ${COV_PATH} ${NAUTILUS_LCOV_ADDITIONAL_ARGS})
  add_custom_target(${COV_NAME}_cleanup
    COMMAND ${COV_CREATE_REUSLT_DIR_CMD}
    COMMAND ${LCOV_CLEANUP_CMD}
    COMMAND ${LCOV_BASELINE_CMD}
    WORKING_DIRECTORY ${TGT_WORKING_DIR}
    BYPRODUCTS ${LCOV_NAME_PREFIX}.base
    VERBATIM
    COMMENT "Running ${NAUTILUS_USE_COVERAGE} to cleanup first."
    )
  add_test(
    NAME ${TARGET_NAME}_coverage_setup
    CONFIGURATIONS Debug
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target ${COV_NAME}_cleanup
    WORKING_DIRECTORY ${TGT_WORKING_DIR}
  )
  set_tests_properties(${TARGET_NAME}_coverage_setup PROPERTIES FIXTURES_SETUP ${TARGET_NAME})
  set_tests_properties(${TARGET_NAME} PROPERTIES DEPENDS ${TARGET_NAME}_coverage_setup)

  set(LCOV_CAPTURE_CMD
    ${COV_FE_PATH} --capture --directory ${PROJECT_BINARY_DIR} --output-file ${LCOV_NAME_PREFIX}.info
    --base-directory ${NAUTILUS_LCOV_BASEDIR} --gcov-tool ${COV_PATH} --branch-coverage ${NAUTILUS_LCOV_ADDITIONAL_ARGS})
  set(LCOV_MERGE_CMD
    ${COV_FE_PATH} --add-tracefile ${LCOV_NAME_PREFIX}.info --add-tracefile ${LCOV_NAME_PREFIX}.base
    ${NAUTILUS_LCOV_ADDITIONAL_ARGS} --branch-coverage --output-file ${LCOV_NAME_PREFIX}.lcov)
  set(LCOV_EXCLUDE_CMD ${COV_FE_PATH} --branch-coverage
    ${LCOV_EXCLUDE_ARGS} --remove ${LCOV_NAME_PREFIX}.lcov "/usr/*" --output-file ${LCOV_NAME_PREFIX}.lcov)
  find_program(GENHTML_PATH genhtml)
  if(NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found!")
  endif()
  set(LCOV_GENHTML_CMD ${GENHTML_PATH} --branch-coverage --demangle-cpp -o ${COV_RESULT_DIR} ${LCOV_NAME_PREFIX}.lcov)

  add_custom_target(${COV_NAME}
    COMMAND ${LCOV_CAPTURE_CMD}
    COMMAND ${LCOV_MERGE_CMD}
    COMMAND ${LCOV_EXCLUDE_CMD}
    COMMAND ${LCOV_GENHTML_CMD}
    BYPRODUCTS
    ${LCOV_NAME_PREFIX}.lcov
    ${LCOV_NAME_PREFIX}.info
    ${COV_RESULT_DIR}/index.html
    WORKING_DIRECTORY ${TGT_WORKING_DIR}
    DEPENDS ${TARGET_NAME}
    VERBATIM # Protect arguments to commands
    COMMENT "Running ${NAUTILUS_USE_COVERAGE} to code coverage report."
    )
endmacro()

macro(__nautilus_coverage_lcov_with_llvmcov)
  set_tests_properties(${TARGET_NAME} PROPERTIES ENVIRONMENT "LLVM_PROFILE_FILE=${TARGET_NAME}.profraw")

  find_program(LLVM_PROFDATA_PATH llvm-profdata)
  if(NOT LLVM_PROFDATA_PATH)
    message(FATAL_ERROR "llvm-profdata not found!")
  endif()

  set(LCOV_PROCESS_CMD ${LLVM_PROFDATA_PATH} merge -sparse ${TGT_WORKING_DIR}/${TARGET_NAME}.profraw -o ${LCOV_NAME_PREFIX}.profdata)
  set(LCOV_EXPORT_CMD ${LLVM_COV_PATH} export $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${LCOV_NAME_PREFIX}.profdata -format=lcov > ${LCOV_NAME_PREFIX}.lcov)
  set(LCOV_EXCLUDE_CMD ${COV_FE_PATH} ${LCOV_EXCLUDE_ARGS} --branch-coverage --output-file ${LCOV_NAME_PREFIX}.lcov)
  find_program(GENHTML_PATH genhtml)
  if(NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found!")
  endif()
  set(LCOV_GENHTML_CMD ${GENHTML_PATH} --demangle-cpp --branch-coverage -o ${COV_RESULT_DIR} ${LCOV_NAME_PREFIX}.lcov)

  add_custom_target(${COV_NAME}
    COMMAND ${COV_CREATE_REUSLT_DIR_CMD}
    COMMAND ${LCOV_PROCESS_CMD}
    COMMAND ${LCOV_EXPORT_CMD}
    COMMAND ${LCOV_EXCLUDE_CMD}
    COMMAND ${LCOV_GENHTML_CMD}
    BYPRODUCTS
    ${LCOV_NAME_PREFIX}.lcov
    ${LCOV_NAME_PREFIX}.profdata
    ${TGT_WORKING_DIR}/${TARGET_NAME}.profraw
    ${COV_RESULT_DIR}/index.html
    WORKING_DIRECTORY ${TGT_WORKING_DIR}
    DEPENDS ${TARGET_NAME}
    VERBATIM # Protect arguments to commands
    COMMENT "Running ${NAUTILUS_USE_COVERAGE} to code coverage report."
    )
endmacro()

function(nautilus_target_coverage_lcov TARGET_NAME)
  if(NOT NAUTILUS_USE_COVERAGE OR NOT NAUTILUS_USE_COVERAGE STREQUAL "lcov")
    return()
  endif()

  __nautilus_coverage_get_gcov()
  __nautilus_coverage_parse_args(NAUTILUS_LCOV ${ARGN})
  __nautilus_coverage_get_excludes(${NAUTILUS_LCOV_BASEDIR} "${NAUTILUS_LCOV_EXCLUDES}")
  __nautilus_coverage_name(${TARGET_NAME} ${NAUTILUS_USE_COVERAGE})
  get_property(TGT_WORKING_DIR TEST ${TARGET_NAME} PROPERTY WORKING_DIRECTORY)
  if(NOT TGT_WORKING_DIR)
    set(TGT_WORKING_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  set(LCOV_NAME_PREFIX "${TGT_WORKING_DIR}/${COV_NAME}")
  set(LCOV_EXCLUDE_ARGS)
  foreach(EXCLUDE ${COV_LIST_EXCLUDES})
    list(APPEND LCOV_EXCLUDE_ARGS "--remove")
    list(APPEND LCOV_EXCLUDE_ARGS "${LCOV_NAME_PREFIX}.lcov")
    list(APPEND LCOV_EXCLUDE_ARGS "${EXCLUDE}")
  endforeach()

  if(NAUTILUS_COMPILER_IS_GCC)
    __nautilus_coverage_lcov_with_gcov()
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    if(NOT LLVM_COV_PATH)
      message(FATAL_ERROR "llvm-cov not found!")
    endif()
    __nautilus_coverage_lcov_with_llvmcov()
  endif()
  add_test(
    NAME ${TARGET_NAME}_coverage
    CONFIGURATIONS Debug
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target ${COV_NAME}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  )
  set_tests_properties(${TARGET_NAME}_coverage PROPERTIES FIXTURES_CLEANUP ${TARGET_NAME})
endfunction()

function(nautilus_target_coverage TARGET_NAME)
  if(NOT NAUTILUS_USE_COVERAGE)
    return()
  endif()
  cmake_language(CALL nautilus_target_coverage_${NAUTILUS_USE_COVERAGE} ${TARGET_NAME} ${ARGN})
endfunction()
