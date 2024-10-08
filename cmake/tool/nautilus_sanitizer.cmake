include_guard()

if(NAUTILUS_USE_SANITIZER STREQUAL "")
  function(nautilus_target_sanitize TARGET_NAME)
  endfunction()
  function(nautilus_target_sanitize_ldpreload TARGET_NAME)
  endfunction()
  return()
endif()

function(nautilus_target_sanitize TARGET_NAME)
  foreach(sanitizer IN LISTS NAUTILUS_USE_SANITIZER)
    if(NAUTILUS_COMPILER_IS_MSVC)
      if(sanitizer STREQUAL "Address")
        list(APPEND NAUTILUS_SAN_KIND address)
      else()
        message(${NAUTILUS_MESSAGE_WARNING}
          "This sanitizer not yet supported in the C / C++ environment: ${sanitizer}")
      endif()
    else(NAUTILUS_COMPILER_IS_MSVC)
      if(sanitizer STREQUAL "Address")
        list(APPEND NAUTILUS_SAN_KIND address)
        list(APPEND NAUTILUS_SAN_COMPILE_OPTIONS
          -fsanitize-address-use-after-scope
        )
        if(NAUTILUS_COMPILER_IS_GCC)
          list(APPEND NAUTILUS_SAN_LINK_OPTIONS -lasan)
        endif()
      elseif(sanitizer MATCHES "Memory(WithOrigins)?")
        # Learn more at https://github.com/google/sanitizers/wiki/MemorySanitizer
        if("Address" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Leak" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Thread" IN_LIST NAUTILUS_USE_SANITIZER)
          message(${NAUTILUS_MESSAGE_WARNING}
            "Memory sanitizer does not work with Address, Leak and Thread sanitizer enabled")
        elseif(NAUTILUS_COMPILER_IS_CLANG)
          list(APPEND NAUTILUS_SAN_KIND memory)
          if(sanitizer STREQUAL "MemoryWithOrigins")
            list(APPEND NAUTILUS_SAN_COMPILE_OPTIONS
              -fsanitize-memory-track-origins
            )
            list(APPEND NAUTILUS_SAN_LINK_OPTIONS
              -fsanitize-memory-track-origins
            )
          endif()
        endif()
      elseif(sanitizer STREQUAL "Undefined")
        # Learn more at https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
        list(APPEND NAUTILUS_SAN_KIND undefined)
        if(NAUTILUS_COMPILER_IS_GCC)
          list(APPEND NAUTILUS_SAN_LINK_OPTIONS -lubsan)
        endif()
      elseif(sanitizer STREQUAL "Thread")
        # Learn more at https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual
        if("Address" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Leak" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Memory" IN_LIST NAUTILUS_USE_SANITIZER OR
            "MemoryWithOrigins" IN_LIST NAUTILUS_USE_SANITIZER)
          message(${NAUTILUS_CMAKE_MESSAGE_WARNING}
            "Thread sanitizer does not work with Address, Leak and Memory sanitizer enabled")
        else()
          list(APPEND NAUTILUS_SAN_KIND thread)
          list(APPEND NAUTILUS_SAN_LINK_OPTIONS -pthread)
          if(NAUTILUS_COMPILER_IS_GCC)
            list(APPEND NAUTILUS_SAN_LINK_OPTIONS -ltsan)
          endif()
        endif()
      elseif(sanitizer STREQUAL "Leak")
        # Learn more at https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer
        list(APPEND NAUTILUS_SAN_KIND leak)
        if(NAUTILUS_COMPILER_IS_GCC)
          list(APPEND NAUTILUS_SAN_LINK_OPTIONS -llsan)
        endif()
      else()
        message(${NAUTILUS_MESSAGE_WARNING}
          "This sanitizer not yet supported in the C / C++ environment: ${sanitizer}")
      endif()
    endif()
  endforeach()

  if(NAUTILUS_COMPILER_IS_MSVC AND NAUTILUS_SAN_KIND)
    list(APPEND NAUTILUS_SAN_COMPILE_OPTIONS
      /fsanitize=${NAUTILUS_SAN_KIND}
      /Oy-
      /Z7 # Always ask the linker to produce symbols with asan.
    )
  elseif(NAUTILUS_SAN_KIND)
    list(JOIN NAUTILUS_SAN_KIND "," NAUTILUS_SAN_KIND_STR)
    list(APPEND NAUTILUS_SAN_COMPILE_OPTIONS
      -fsanitize=${NAUTILUS_SAN_KIND_STR}
      -fno-omit-frame-pointer
      -O1
    )
    list(APPEND NAUTILUS_SAN_LINK_OPTIONS
      -fsanitize=${NAUTILUS_SAN_KIND_STR}
    )
    if(NAUTILUS_COMPILER_IS_CLANG)
      list(APPEND NAUTILUS_SAN_LINK_OPTIONS -shared-libsan)
    endif()
    get_property(NAUTILUS_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
    if(CXX IN_LIST NAUTILUS_LANGUAGES)
      list(APPEND NAUTILUS_SAN_COMPILE_OPTIONS
        -fno-sanitize=vptr
      )
      if(NAUTILUS_COMPILER_IS_CLANG)
        list(APPEND NAUTILUS_SAN_LINK_OPTIONS
          -fsanitize-link-c++-runtime
        )
      endif()
    endif()
  endif()

  get_target_property(TARGET_LINK_OPTIONS_VAR ${TARGET_NAME} LINK_OPTIONS)
  if("${TARGET_LINK_OPTIONS_VAR}" STREQUAL "TARGET_LINK_OPTIONS_VAR-NOTFOUND")
    set(TARGET_LINK_OPTIONS_VAR ${NAUTILUS_SAN_LINK_OPTIONS})
  else()
    list(APPEND TARGET_LINK_OPTIONS_VAR ${NAUTILUS_SAN_LINK_OPTIONS})
  endif()
  set_target_properties(${TARGET_NAME} PROPERTIES LINK_OPTIONS "${TARGET_LINK_OPTIONS_VAR}")
  get_target_property(TARGET_COMPILE_OPTIONS_VAR ${TARGET_NAME} COMPILE_OPTIONS)
  if("${TARGET_COMPILE_OPTIONS_VAR}" STREQUAL "TARGET_COMPILE_OPTIONS_VAR-NOTFOUND")
    set(TARGET_COMPILE_OPTIONS_VAR ${NAUTILUS_SAN_COMPILE_OPTIONS})
  else()
    list(APPEND TARGET_COMPILE_OPTIONS_VAR ${NAUTILUS_SAN_COMPILE_OPTIONS})
  endif()
  set_target_properties(${TARGET_NAME} PROPERTIES COMPILE_OPTIONS "${TARGET_COMPILE_OPTIONS_VAR}")
endfunction()

function(nautilus_target_sanitize_ldpreload TARGET_NAME)
  macro(SEARCH_LIBSAN_PATH LIBNAME POSTFIX)
    if(NAUTILUS_COMPILER_IS_GCC)
      execute_process(COMMAND gcc -print-file-name=lib${LIBNAME}.so
        OUTPUT_VARIABLE LIBSAN_DYNAMIC_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    else() # clang
      set(LIBNAME_POSTFIX ${POSTFIX})
      if(NOT NAUTILUS_ARCH_IS_64BIT)
        message(FATAL_ERROR "32bit doesn't have clang_rt library")
      endif()
      if(NAUTILUS_ARCH_IS_ARM)
        pstring(APPEND LIBNAME_POSTFIX "-aarch64")
      elseif(NAUTILUS_ARCH_IS_POWERPC)
        string(APPEND LIBNAME_POSTFIX "-powerpc64le")
      elseif(NAUTILUS_ARCH_IS_RISCV)
        message(FATAL_ERROR "Unknow arch: RISCV")
      elseif(NAUTILUS_ARCH_IS_X86)
        string(APPEND LIBNAME_POSTFIX "-x86_64")
      endif()
      execute_process(COMMAND clang -print-file-name=libclang_rt.${LIBNAME}${LIBNAME_POSTFIX}.so
        OUTPUT_VARIABLE LIBSAN_DYNAMIC_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    if(EXISTS ${LIBSAN_DYNAMIC_PATH})
      set(LIBSAN_PATH "${LIBSAN_DYNAMIC_PATH}")
    endif()
  endmacro()
  set(LDPRELOAD_VARLIST)
  foreach(sanitizer IN LISTS NAUTILUS_USE_SANITIZER)
    set(LIBSAN_PATH)
    if(sanitizer STREQUAL "Address")
      SEARCH_LIBSAN_PATH(asan "")
    elseif(sanitizer MATCHES "Memory(WithOrigins)?")
      SEARCH_LIBSAN_PATH(msan "")
    elseif(sanitizer STREQUAL "Undefined")
      SEARCH_LIBSAN_PATH(ubsan "_standalone")
    elseif(sanitizer STREQUAL "Thread")
      SEARCH_LIBSAN_PATH(tsan "")
    elseif(sanitizer STREQUAL "Leak")
      SEARCH_LIBSAN_PATH(lsan "")
    endif()
    if(LIBSAN_PATH)
      list(APPEND LDPRELOAD_VARLIST ${LIBSAN_PATH})
    endif()
  endforeach()
  list(JOIN LDPRELOAD_VARLIST ":" LDPRELOAD_VAR)
  if(CMAKE_VERSION VERSION_LESS 3.22)
    set_property(TEST ${TARGET_NAME} PROPERTY
      ENVIRONMENT "LD_PRELOAD=$ENV{LD_PRELOAD}:${LDPRELOAD_VAR}"
    )
  else()
    set_property(TEST ${TARGET_NAME} PROPERTY
      ENVIRONMENT_MODIFICATION "LD_PRELOAD=path_list_prepend:${LDPRELOAD_VAR}"
    )
  endif()
endfunction()
