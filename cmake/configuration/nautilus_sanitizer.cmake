include_guard()

set(NAUTILUS_ADDED_SANITIZER OFF)
foreach(sanitizer IN LISTS NAUTILUS_USE_SANITIZER)
  if(sanitizer STREQUAL "Address")
    # Learn more at https://github.com/google/sanitizers/wiki/AddressSanitizer
    list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
      $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=address,-fsanitize=address\;-fsanitize-address-use-after-scope>)
    list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
      $<$<NOT:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>>:-lasan>
      $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=address,-fsanitize=address>)
    set(NAUTILUS_ADDED_SANITIZER ON)
  elseif(sanitizer MATCHES "Memory(WithOrigins)?")
    # Learn more at https://github.com/google/sanitizers/wiki/MemorySanitizer
    if("Address" IN_LIST NAUTILUS_USE_SANITIZER OR
        "Leak" IN_LIST NAUTILUS_USE_SANITIZER OR
        "Thread" IN_LIST NAUTILUS_USE_SANITIZER)
      message(${NAUTILUS_MESSAGE_WARNING}
        "Memory sanitizer does not work with Address, Leak and Thread sanitizer enabled")
    elseif(NOT NAUTILUS_COMPILER_IS_GCC)
      list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
        $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=memory,-fsanitize=memory>)
      list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
        $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=memory,-fsanitize=memory>)
      if(NAUTILUS_COMPILER_IS_CLANG AND sanitizer STREQUAL "MemoryWithOrigins")
        list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP -fsanitize-memory-track-origins)
        list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP -fsanitize-memory-track-origins)
      endif()
      set(NAUTILUS_ADDED_SANITIZER ON)
    endif()
  elseif(sanitizer MATCHES "Undefined")
    # Learn more at https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
    list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
      $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=undefined,-fsanitize=undefined>
      $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>>>:-fno-sanitize=vptr>)
    list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
      $<$<NOT:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>>:-lubsan>
      $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=undefined,-fsanitize=undefined>)
    set(NAUTILUS_ADDED_SANITIZER ON)
  elseif(sanitizer MATCHES "Thread")
    # Learn more at https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual
    if("Address" IN_LIST NAUTILUS_USE_SANITIZER OR
        "Leak" IN_LIST NAUTILUS_USE_SANITIZER OR
        "Memory" IN_LIST NAUTILUS_USE_SANITIZER OR
        "MemoryWithOrigins" IN_LIST NAUTILUS_USE_SANITIZER)
      message(${NAUTILUS_CMAKE_MESSAGE_WARNING}
        "Thread sanitizer does not work with Address, Leak and Memory sanitizer enabled")
    else()
      list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
        $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=thread\;/O1,-fsanitize=thread\;-O1>)
      list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
        $<$<NOT:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>>:-ltsan>
        $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=thread,-fsanitize=thread>)
      set(NAUTILUS_ADDED_SANITIZER ON)
    endif()
  elseif(sanitizer MATCHES "Leak")
    # Learn more at https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer
    list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP
      $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=leak,-fsanitize=leak>)
    list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
      $<$<NOT:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>>:-ltsan>
      $<IF:$<BOOL:${NAUTILUS_COMPILER_IS_MSVC}>,/fsanitize=leak,-fsanitize=leak>)
    set(NAUTILUS_ADDED_SANITIZER ON)
  else()
    message(${NAUTILUS_MESSAGE_WARNING}
      "This sanitizer not yet supported in the C / C++ environment: ${sanitizer}")
  endif()
endforeach()

if(NOT NAUTILUS_COMPILER_IS_MSVC AND NAUTILUS_ADDED_SANITIZER)
  list(APPEND NAUTILUS_COMPILE_OPTIONS_DEVELOP -fno-omit-frame-pointer)
endif()
unset(NAUTILUS_ADDED_SANITIZER)
