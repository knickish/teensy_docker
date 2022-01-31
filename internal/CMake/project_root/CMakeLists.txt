cmake_minimum_required(VERSION 3.13)
project(TEENSY)

include(macros.cmake)


enable_language(CXX C ASM)
set(SOURCE)
list(APPEND EXTRA_INCLUDE_LIBS)
list(APPEND EXTRA_LINK_LIBS)
set(TEENSY_VERSION $ENV{TEENSY_VERSION})

#CPP and C Flags
set(CXXFLAGS " -Wall -g -mthumb -MMD -I. -DUSB_SERIAL -DLAYOUT_US_ENGLISH")

#CPP only
set(CPPFLAGS "-fexceptions")

# compiler options for C only
set(CFLAGS "")

# linker options
set(LDFLAGS "")

# additional libraries to link
set(LIBS "")


# compiler options specific to teensy version
if (TEENSY_VERSION EQUAL 30)
    set(OPTIONS "-DF_CPU=48000000 -DARDUINO=10805 -DTEENSYDUINO=144")
    set(CXXFLAGS "${CXXFLAGS} -D__MK20DX128__ -mcpu=cortex-m4 -Os")
    set(LDSCRIPT mk20dx128.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4  -T/teensyduino/bin/${LDSCRIPT}")

elseif (TEENSY_VERSION EQUAL 31)
    set(OPTIONS "-DF_CPU=48000000 -DARDUINO=10805 -DTEENSYDUINO=144")
    set(CXXFLAGS "${CXXFLAGS} -D__MK20DX256__ -mcpu=cortex-m4 -Os")
    set(LDSCRIPT mk20dx256.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4  -T/teensyduino/bin/${LDSCRIPT}")

elseif (TEENSY_VERSION EQUAL 32)
    set(OPTIONS "-DF_CPU=48000000  -DARDUINO=10805 -DTEENSYDUINO=144")
    set(CXXFLAGS "${CXXFLAGS} -D__MK20DX256__ -mcpu=cortex-m4 -Os")
    set(LDSCRIPT mk20dx256.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 -T/teensyduino/bin/${LDSCRIPT}")

elseif (TEENSY_VERSION STREQUAL "LC")
    message(STATUS "Compiling for Teensy LC")
    set(OPTIONS "-DF_CPU=48000000 -DARDUINO=10805 -DTEENSYDUINO=144 -DUSING_MAKEFILE")
    set(CXXFLAGS "${CXXFLAGS} -D__MKL26Z64__ -mcpu=cortex-m0plus -Os")
    set(LDSCRIPT mkl26z64.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m0plus -T/teensyduino/bin/${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM0l_math")

elseif (TEENSY_VERSION EQUAL 35)
    message(STATUS "Compiling for Teensy 3.5")
    set(OPTIONS "-DF_CPU=48000000 -DARDUINO=10805 -DTEENSYDUINO=144")
    set(CXXFLAGS "${CXXFLAGS} -D__MK64FX512__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Os" )
    set(LDSCRIPT mk64fx512.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16  -T/teensyduino/bin/${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM4lf_math")

elseif (TEENSY_VERSION EQUAL 36)
    message(STATUS "Compiling for Teensy 3.6")
    set(OPTIONS "-DF_CPU=48000000 -DARDUINO=10805 -DTEENSYDUINO=144")
    set(CXXFLAGS "${CXXFLAGS} -D__MK66FX1M0__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Os")
    set(LDSCRIPT mk66fx1m0.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16  -T/teensyduino/bin/${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM4lf_math")

elseif (TEENSY_VERSION EQUAL 40)
    message(STATUS "Compiling for Teensy 4.0")
    set(OPTIONS "-DF_CPU=600000000 -DARDUINO=10810 -DTEENSYDUINO=149 -DARDUINO_TEENSY40")
    set(CXXFLAGS "${CXXFLAGS} -D__IMXRT1062__ -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -Wno-error=narrowing -O2")
    set(CPPFLAGS "${CPPFLAGS} ")
    set(LDSCRIPT imxrt1062.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -T/teensyduino/bin/${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM7lfsp_math -lstdc++")

elseif (TEENSY_VERSION EQUAL 41)
    message(STATUS "Compiling for Teensy 4.1")
    set(OPTIONS "-DF_CPU=600000000 -DARDUINO=10810 -DTEENSYDUINO=149 -DARDUINO_TEENSY41")
    set(CXXFLAGS "${CXXFLAGS} -D__IMXRT1062__ -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -Wno-error=narrowing -O2")
    set(CPPFLAGS "${CPPFLAGS}")
    set(LDSCRIPT imxrt1062_t41.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -T/teensyduino/bin/${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM7lfsp_math  -lstdc++")

endif ()

set(CXXFLAGS "${CXXFLAGS} -Wall -g -mthumb -MMD -I. ${OPTIONS}")

#CPP only
set(CPPFLAGS "${CXXFLAGS} ${CPPFLAGS} -felide-constructors -fno-rtti -std=gnu++17 ")

# compiler options for C only
set(CFLAGS "${CXXFLAGS}" )

# linker options
set(LDFLAGS "${LDFLAGS} -L/teensyduino/include -Os -Wl,--gc-sections,--defsym=__rtc_localtime=0,--relax --specs=/teensyduino/include/nano.specs -mthumb -R/teensyduino/bin")

# additional libraries to link
set(LIBS "${LIBS} -lm")

set(LDFLAGS "${LDFLAGS} ${LIBS}")
SET ( CMAKE_CXX_FLAGS ${CPPFLAGS} CACHE STRING "c++ compile flags" FORCE)
SET ( CMAKE_C_FLAGS ${CFLAGS} CACHE STRING "c compile flags" FORCE)
SET ( CMAKE_EXE_LINKER_FLAGS ${LDFLAGS} CACHE STRING "linker flags" FORCE)
SET ( CMAKE_ASM_FLAGS ${CFLAGS} CACHE STRING "asm compile flags" FORCE)

add_subdirectory(src)
if ( TEENSY_VERSION EQUAL 30 OR TEENSY_VERSION EQUAL 31 OR TEENSY_VERSION EQUAL 32 OR TEENSY_VERSION EQUAL 35 OR TEENSY_VERSION EQUAL 36 OR TEENSY_VERSION STREQUAL "LC")
    message(STATUS "Using Teensy3 Core")
    include_directories(cores/teensy3)
    add_subdirectory(cores/teensy3)
    add_executable(MAIN ${SOURCE})
    target_link_libraries(MAIN PUBLIC ${EXTRA_LINK_LIBS})
elseif (TEENSY_VERSION EQUAL 40 OR TEENSY_VERSION EQUAL 41)
    message(STATUS "Using Teensy4 Core")
    include_directories(cores/teensy4)
    add_subdirectory(cores/teensy4)
    add_executable(MAIN ${SOURCE})
    target_link_libraries(MAIN PUBLIC ${EXTRA_LINK_LIBS} )
endif()

include_directories(include)
include_directories(bin/include)
include_directories(bin)
include_directories(bin/include-fixed)
include_directories(include/c++/5.4.1)
include_directories(include/c++/5.4.1/arm-none-eabi)



add_subdirectory(libraries)
link_directories(libraries)
message(STATUS ${EXTRA_LINK_LIBS} )
message(STATUS ${EXTRA_INCLUDE_LIBS} )
target_link_libraries(MAIN PUBLIC ${EXTRA_LINK_LIBS} )
target_include_directories(MAIN PUBLIC ${EXTRA_INCLUDE_LIBS} )


add_custom_command(
  TARGET MAIN POST_BUILD
  COMMAND arm-none-eabi-objcopy -O ihex -R .eeprom MAIN main.hex
  VERBATIM)