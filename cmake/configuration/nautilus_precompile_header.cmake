include_guard()

function(nautilus_target_pch TARGET_NAME)
  if(NOT NAUTILUS_ENABLE_PCH)
    return()
  endif()
  if(CMAKE_VERSION VERSION_LESS 3.16)
    message(${NAUTILUS_MESSAGE_WARNING} "Consider upgrading CMake to 3.16 or latest, current version ${CMAKE_VERSION} does not support PCH.")
    return()
  endif()
  if(NOT NAUTILUS_COMPILER_IS_CLANG AND NAUTILUS_ENABLE_LINT)
    message(${NAUTILUS_MESSAGE_WARNING} "clang-tidy not support with non-clang pch")
    return()
  endif()

  set(options THREAD)
  set(oneValueArgs)
  set(multiValueArgs PUBLIC INTERFACE PRIVATE)
  cmake_parse_arguments(NAUTILUS_PCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  get_property(NAUTILUS_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
  get_target_property(C_STANDARD_VAR ${TARGET_NAME} C_STANDARD)
  if(C_STANDARD_VAR MATCHES "-NOTFOUND" OR C_STANDARD_VAR STREQUAL 99)
    set(C_STANDARD_VAR 0)
  endif()
  get_target_property(CXX_STANDARD_VAR ${TARGET_NAME} CXX_STANDARD)

  target_precompile_headers(${TARGET_NAME} PUBLIC
    <assert.h$<ANGLE-R>
    <complex.h$<ANGLE-R>
    <ctype.h$<ANGLE-R>
    <errno.h$<ANGLE-R>
    <fenv.h$<ANGLE-R>
    <float.h$<ANGLE-R>
    <inttypes.h$<ANGLE-R>
    <iso646.h$<ANGLE-R>
    <limits.h$<ANGLE-R>
    <math.h$<ANGLE-R>
    <setjmp.h$<ANGLE-R>
    <stdarg.h$<ANGLE-R>
    <stddef.h$<ANGLE-R>
    <stdint.h$<ANGLE-R>
    <stdio.h$<ANGLE-R>
    <stdlib.h$<ANGLE-R>
    <string.h$<ANGLE-R>
    <tgmath.h$<ANGLE-R>
    <time.h$<ANGLE-R>
  )
  if(C_STANDARD_VAR GREATER_EQUAL 11)
    target_precompile_headers(${TARGET_NAME} PUBLIC
      <signal.h$<ANGLE-R>
      <stdnoreturn.h$<ANGLE-R>
      <uchar.h$<ANGLE-R>
      )
  endif()
  if(C_STANDARD_VAR GREATER_EQUAL 23)
    target_precompile_headers(${TARGET_NAME} PUBLIC
      <stdbit.h$<ANGLE-R>
      <stdckdint.h$<ANGLE-R>
      )
  endif()
  if(NAUTILUS_PCH_THREAD AND C_STANDARD_VAR GREATER_EQUAL 11)
    target_precompile_headers(${TARGET_NAME} PUBLIC
      <stdatomic.h$<ANGLE-R>
      <threads.h$<ANGLE-R>
      )
  endif()
  if(CXX IN_LIST NAUTILUS_LANGUAGES)
   target_precompile_headers(${TARGET_NAME} PUBLIC
      <bitset$<ANGLE-R>
      <chrono$<ANGLE-R>
      <functional$<ANGLE-R>
      <initializer_list$<ANGLE-R>
      <tuple$<ANGLE-R>
      <type_traits$<ANGLE-R>
      <typeindex$<ANGLE-R>
      <typeinfo$<ANGLE-R>
      <utility$<ANGLE-R>
      <memory$<ANGLE-R>
      <new$<ANGLE-R>
      <scoped_allocator$<ANGLE-R>
      <limits$<ANGLE-R>
      <exception$<ANGLE-R>
      <stdexcept$<ANGLE-R>
      <system_error$<ANGLE-R>
      <string$<ANGLE-R>
      <array$<ANGLE-R>
      <deque$<ANGLE-R>
      <forward_list$<ANGLE-R>
      <list$<ANGLE-R>
      <map$<ANGLE-R>
      <queue$<ANGLE-R>
      <set$<ANGLE-R>
      <stack$<ANGLE-R>
      <unordered_map$<ANGLE-R>
      <unordered_set$<ANGLE-R>
      <vector$<ANGLE-R>
      <iterator$<ANGLE-R>
      <algorithm$<ANGLE-R>
      <complex$<ANGLE-R>
      <numeric$<ANGLE-R>
      <random$<ANGLE-R>
      <ratio$<ANGLE-R>
      <valarray$<ANGLE-R>
      <fstream$<ANGLE-R>
      <iomanip$<ANGLE-R>
      <ios$<ANGLE-R>
      <iosfwd$<ANGLE-R>
      <iostream$<ANGLE-R>
      <istream$<ANGLE-R>
      <ostream$<ANGLE-R>
      <sstream$<ANGLE-R>
      <streambuf$<ANGLE-R>
      <regex$<ANGLE-R>
      )
    if(CXX_STANDARD_VAR GREATER_EQUAL 17)
      target_precompile_headers(${TARGET_NAME} PUBLIC
        <any$<ANGLE-R>
        <optional$<ANGLE-R>
        <variant$<ANGLE-R>
        <memory_resource$<ANGLE-R>
        <charconv$<ANGLE-R>
        <string_view$<ANGLE-R>
        <execution$<ANGLE-R>
        <filesystem$<ANGLE-R>
        )
    endif()
    if(CXX_STANDARD_VAR GREATER_EQUAL 20)
      target_precompile_headers(${TARGET_NAME} PUBLIC
        <concepts$<ANGLE-R>
        <coroutine$<ANGLE-R>
        <compare$<ANGLE-R>
        <version$<ANGLE-R>
        <format$<ANGLE-R>
        <span$<ANGLE-R>
        <ranges$<ANGLE-R>
        <bit$<ANGLE-R>
        <numbers$<ANGLE-R>
        <syncstream$<ANGLE-R>
        )
    endif()
    if(CXX_STANDARD_VAR GREATER_EQUAL 23)
      target_precompile_headers(${TARGET_NAME} PUBLIC
        <expected$<ANGLE-R>
        <stdfloat$<ANGLE-R>
        <flat_map$<ANGLE-R>
        <flat_set$<ANGLE-R>
        <mdspan$<ANGLE-R>
        <generator$<ANGLE-R>
        <print$<ANGLE-R>
        <spanstream$<ANGLE-R>
        )
    endif()
    if(NAUTILUS_PCH_THREAD)
      target_precompile_headers(${TARGET_NAME} PUBLIC
        <atomic$<ANGLE-R>
        <condition_variable$<ANGLE-R>
        <future$<ANGLE-R>
        <mutex$<ANGLE-R>
        <thread$<ANGLE-R>
        )
    endif()
    if(NAUTILUS_PCH_THREAD AND CXX_STANDARD_VAR GREATER_EQUAL 14)
      target_precompile_headers(${TARGET_NAME} PUBLIC
        <shared_mutex$<ANGLE-R>
        )
    endif()
    if(NAUTILUS_PCH_THREAD AND CXX_STANDARD_VAR GREATER_EQUAL 20)
      target_precompile_headers(${TARGET_NAME} PUBLIC
        <barrier$<ANGLE-R>
        <latch$<ANGLE-R>
        <semaphore$<ANGLE-R>
        <stop_token$<ANGLE-R>
        )
    endif()
  endif()

  target_precompile_headers(${TARGET_NAME}
    PUBLIC ${NAUTILUS_PCH_PUBLIC}
    INTERFACE ${NAUTILUS_PCH_INTERFACE}
    PRIVATE ${NAUTILUS_PCH_PRIVATE}
    )
endfunction()

function(nautilus_target_reuse_pch TARGET_NAME REUSED_TARGET_NAME)
  if(NOT NAUTILUS_ENABLE_PCH OR TARGET_NAME STREQUAL REUSED_TARGET_NAME)
    return()
  endif()
  set(options)
  set(oneValueArgs)
  set(multiValueArgs PUBLIC INTERFACE PRIVATE)
  cmake_parse_arguments(NAUTILUS_PCH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  target_precompile_headers(${TARGET_NAME} REUSE_FROM
    ${REUSED_TARGET_NAME}
  )

  target_precompile_headers(${TARGET_NAME}
    PUBLIC ${NAUTILUS_PCH_PUBLIC}
    INTERFACE ${NAUTILUS_PCH_INTERFACE}
    PRIVATE ${NAUTILUS_PCH_PRIVATE}
    )
endfunction()
