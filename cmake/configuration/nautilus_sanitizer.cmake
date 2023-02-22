include_guard()

if(NAUTILUS_USE_SANITIZER)
  function(nautilus_get_sanitize_flags)
    foreach(sanitizer IN LISTS NAUTILUS_USE_SANITIZER)
      if(sanitizer STREQUAL "Address")
        list(APPEND compile_flags
          "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=address,-fsanitize=address\;-fsanitize-address-use-after-scope>")
        list(APPEND link_flags
          "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=address,-fsanitize=address>")
      elseif(sanitizer MATCHES "Memory(WithOrigins)?")
        if("Address" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Leak" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Thread" IN_LIST NAUTILUS_USE_SANITIZER)
          message(${NAUTILUS_MESSAGE_WARNING}
            "Memory sanitizer does not work with Address, Leak and Thread sanitizer enabled")
        elseif(NOT NAUTILUS_COMPILER_IS_GCC)
          list(APPEND compile_flags "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=memory,-fsanitize=memory>")
          list(APPEND link_flags    "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=memory,-fsanitize=memory>")
          if(NAUTILUS_COMPILER_IS_CLANG AND sanitizer STREQUAL "MemoryWithOrigins")
            list(APPEND compile_flags -fsanitize-memory-track-origins)
            list(APPEND link_flags    -fsanitize-memory-track-origins)
          endif()
        endif()
      elseif(sanitizer MATCHES "Undefined")
        list(APPEND compile_flags
          "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=undefined,-fsanitize=undefined\;-fno-sanitize=vptr>")
        list(APPEND link_flags
          "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=undefined,-fsanitize=undefined>")
      elseif(sanitizer MATCHES "Thread")
        if("Address" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Leak" IN_LIST NAUTILUS_USE_SANITIZER OR
            "Memory" IN_LIST NAUTILUS_USE_SANITIZER OR
            "MemoryWithOrigins" IN_LIST NAUTILUS_USE_SANITIZER)
          message(${NAUTILUS_CMAKE_MESSAGE_WARNING}
            "Thread sanitizer does not work with Address, Leak and Memory sanitizer enabled")
        else()
          list(APPEND compile_flags "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=thread,-fsanitize=thread>")
          list(APPEND link_flags    "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=thread,-fsanitize=thread>")
        endif()
      elseif(sanitizer MATCHES "Leak")
        list(APPEND compile_flags "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=leak,-fsanitize=leak>")
        list(APPEND link_flags    "$<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=leak,-fsanitize=leak>")
      else()
        message(${NAUTILUS_MESSAGE_WARNING}
          "This sanitizer not yet supported in the C++ environment: ${sanitizer}")
      endif()
    endforeach()
    if(NOT NAUTILUS_COMPILER_IS_MSVC AND compile_flags)
      list(APPEND compile_flags -fno-omit-frame-pointer)
    endif()
    add_compile_options(${compile_flags})
    add_link_options(${link_flags})
  endfunction()
  get_sanitize_flags()
endif()
