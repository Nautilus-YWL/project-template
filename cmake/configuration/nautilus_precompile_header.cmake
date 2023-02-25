include_guard()

function(target_enable_pch TARGET_NAME)
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

  set(NAUTILUS_PCH_C_HEADERS
    <assert.h$<ANGLE-R>
    <complex.h$<ANGLE-R>
    <ctype.h$<ANGLE-R>
    <errno.h$<ANGLE-R>
    <fenv.h$<ANGLE-R>
    <float.h$<ANGLE-R>
    <inttypes.h$<ANGLE-R>
    <limits.h$<ANGLE-R>
    <math.h$<ANGLE-R>
    <signal.h$<ANGLE-R>
    <stdarg.h$<ANGLE-R>
    <stddef.h$<ANGLE-R>
    <stdint.h$<ANGLE-R>
    <stdio.h$<ANGLE-R>
    <stdlib.h$<ANGLE-R>
    <string.h$<ANGLE-R>
    <time.h$<ANGLE-R>
    )
  set(NAUTILUS_PCH_CXX_HEADERS
    <algorithm$<ANGLE-R>
    <array$<ANGLE-R>
    <bitset$<ANGLE-R>
    <chrono$<ANGLE-R>
    <complex$<ANGLE-R>
    <deque$<ANGLE-R>
    <exception$<ANGLE-R>
    <initializer_list$<ANGLE-R>
    <iterator$<ANGLE-R>
    <limits$<ANGLE-R>
    <list$<ANGLE-R>
    <map$<ANGLE-R>
    <memory$<ANGLE-R>
    <new$<ANGLE-R>
    <numeric$<ANGLE-R>
    <queue$<ANGLE-R>
    <random$<ANGLE-R>
    <ratio$<ANGLE-R>
    <set$<ANGLE-R>
    <sstream$<ANGLE-R>
    <stack$<ANGLE-R>
    <stdexcept$<ANGLE-R>
    <string$<ANGLE-R>
    <system_error$<ANGLE-R>
    <tuple$<ANGLE-R>
    <type_traits$<ANGLE-R>
    <typeindex$<ANGLE-R>
    <typeinfo$<ANGLE-R>
    <unordered_map$<ANGLE-R>
    <unordered_set$<ANGLE-R>
    <utility$<ANGLE-R>
    <valarray$<ANGLE-R>
    <vector$<ANGLE-R>
    )
  set(NAUTILUS_PCH_C_THREAD_HEADERS
    <stdatomic.h$<ANGLE-R>
    <threads.h$<ANGLE-R>
    )
  set(NAUTILUS_PCH_CXX_THREAD_HEADERS
    <atomic$<ANGLE-R>
    <condition_variable$<ANGLE-R>
    <future$<ANGLE-R>
    <mutex$<ANGLE-R>
    <thread$<ANGLE-R>
    )

  target_precompile_headers(${TARGET_NAME} PUBLIC
    "$<$<COMPILE_LANGUAGE:C>:${NAUTILUS_PCH_C_HEADERS}>"
    "$<$<COMPILE_LANGUAGE:CXX>:${NAUTILUS_PCH_CXX_HEADERS}>"
    )
  if(NAUTILUS_PCH_THREAD)
    target_precompile_headers(${TARGET_NAME} PUBLIC
      "$<$<COMPILE_LANGUAGE:C>:${NAUTILUS_PCH_C_THREAD_HEADERS}>"
      "$<$<COMPILE_LANGUAGE:CXX>:${NAUTILUS_PCH_CXX_THREAD_HEADERS}>"
      )
  endif()
  target_precompile_headers(${TARGET_NAME} PUBLIC
    ${NAUTILUS_PCH_PUBLIC}
    )
  target_precompile_headers(${TARGET_NAME} INTERFACE
    ${NAUTILUS_PCH_INTERFACE}
    )
  target_precompile_headers(${TARGET_NAME} PRIVATE
    ${NAUTILUS_PCH_PRIVATE}
    )
endfunction()
