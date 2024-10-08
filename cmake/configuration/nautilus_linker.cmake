include_guard()

function(nautilus_target_ipo TARGET_NAME)
  if(NOT NAUTILUS_ENABLE_IPO)
    return()
  endif()
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if(result)
    set_target_properties(${TARGET_NAME} PROPERTIES
      INTERPROCEDURAL_OPTIMIZATION ON)
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "IPO is not supported: ${output}.")
  endif()
endfunction()

macro(_NAUTILUS_LINKER_CONFIG_GCC)
  list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
    $<$<NOT:$<BOOL:$<STREQUAL:${NAUTILUS_USE_COVERAGE},"">>>:--coverage>
    )
  if(NAUTILUS_USE_STDLIB)
    list(APPEND NAUTILUS_LINK_OPTIONS_COMMON
      -lm
      -lc
      -nodefaultlibs
      $<$<PLATFORM_ID:Linux>:-lgcc_s\;-lgcc>
      $<IF:$<AND:$<BOOL:${NAUTILUS_TARGET_IS_32BIT}>,$<NOT:$<BOOL:${NAUTILUS_ARCH_IS_32BIT}>>>,-m32,-march=native>
    )
  endif()
  if(NAUTILUS_USE_STDLIB AND C IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -nostdlib
      )
  endif()
  if(NAUTILUS_USE_STDLIB AND CXX IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_COMPILE_OPTIONS_COMMON
      -nostdlib++
      $<$<STREQUAL:${NAUTILUS_USE_STDLIB},cxx>:-lc++\;-lc++abi\;-lsupc++>
      $<$<STREQUAL:${NAUTILUS_USE_STDLIB},stdcxx>:-lstdc++>
      )
  endif()
endmacro()

macro(_NAUTILUS_LINKER_CONFIG_CLANG)
  list(APPEND NAUTILUS_LINK_OPTIONS_DEVELOP
    # --coverage is equivalent to -ftest-profile -fprofile-arcs
    $<$<NOT:$<BOOL:$<STREQUAL:${NAUTILUS_USE_COVERAGE},"">>>:
      $<IF:$<BOOL:$<STREQUAL:${NAUTILUS_USE_COVERAGE},"gcovr">>,
        --coverage,
        -fprofile-instr-generate\;-fcoverage-mapping>>
    )
  if(NAUTILUS_USE_STDLIB AND CXX IN_LIST NAUTILUS_LANGUAGES)
    list(APPEND NAUTILUS_LINK_OPTIONS_COMMON
      $<$<STREQUAL:${NAUTILUS_USE_STDLIB},cxx>:-stdlib=libc++\;-lc++>
      )
  endif()
endmacro()

get_property(NAUTILUS_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
if(NAUTILUS_COMPILER_IS_MSVC)
else()
  list(APPEND NAUTILUS_LINK_OPTIONS_COMMON
    $<$<BOOL:${NAUTILUS_USE_LINKER}>:-fuse-ld=${NAUTILUS_USE_LINKER}>
    )
  if(NAUTILUS_COMPILER_IS_GCC)
    _NAUTILUS_LINKER_CONFIG_GCC()
  elseif(NAUTILUS_COMPILER_IS_CLANG)
    _NAUTILUS_LINKER_CONFIG_CLANG()
  else()
    message(${NAUTILUS_MESSAGE_WARNING} "Unknow compiler ${CMAKE_CXX_COMPILER_ID}.")
  endif()
endif()
unset(NAUTILUS_LANGUAGES)
