cmake_minimum_required(VERSION 3.13)
project(TEENSY)

include(macros.cmake)
enable_language(CXX C)
set(SOURCE)
list(APPEND EXTRA_LIBS)
set(TEENSY_VERSION $ENV{TEENSY_VERSION})
add_subdirectory(src)
message(STATUS ${TEENSY_VERSION})
if ( TEENSY_VERSION EQUAL 30 OR TEENSY_VERSION EQUAL 31 OR TEENSY_VERSION EQUAL 32 OR TEENSY_VERSION EQUAL 35 OR TEENSY_VERSION EQUAL 36)
    include_directories(cores/teensy3)
    add_subdirectory(cores/teensy3)
    add_executable(MAIN ${SOURCE})
    target_link_libraries(MAIN PUBLIC ${EXTRA_LIBS})
elseif (TEENSY_VERSION EQUAL 40 OR TEENSY_VERSION EQUAL 41)
    include_directories(cores/teensy4)
    add_subdirectory(cores/teensy4)
    add_executable(MAIN ${SOURCE})
    target_link_libraries(MAIN PUBLIC ${EXTRA_LIBS} )
else()
    include_directories(cores/teensy)
    add_subdirectory(cores/teensy)
    add_executable(MAIN ${SOURCE})
    target_link_libraries(MAIN PUBLIC ${EXTRA_LIBS} )
endif()

include_directories(include)
include_directories(bin/include)
include_directories(bin)
include_directories(bin/include-fixed)
include_directories(include/c++/5.4.1)
include_directories(include/c++/5.4.1/arm-none-eabi)

#CPP and C Flags
set(CXXFLAGS "-Wall -g -Os -mthumb -MMD -I. -DLowPower_h=1 -DF_CPU=48000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -DARDUINO=10805 -DTEENSYDUINO=144")

#CPP only
set(CPPFLAGS "${CXXFLAGS} -felide-constructors -fno-exceptions -fno-rtti -std=gnu++14 ")

# compiler options for C only
set(CFLAGS "${CXXFLAGS}" )

# linker options
set(LDFLAGS "-L/teensyduino/include -Wl,--gc-sections,--defsym=__rtc_localtime=0 --specs=/teensyduino/include/nano.specs -mthumb -R/teensyduino/bin")


# additional libraries to link
set(LIBS "-lm")

# compiler options specific to teensy version
if (TEENSY_VERSION EQUAL 30)
    set(CPPFLAGS "${CPPFLAGS} -D__MK20DX128__ -mcpu=cortex-m4")
    set(CFLAGS "${CFLAGS} -D__MK20DX128__ -mcpu=cortex-m4")
    set(LDSCRIPT mk20dx128.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 ${LDSCRIPT}")
elseif (TEENSY_VERSION EQUAL 31)
    set(CPPFLAGS "${CPPFLAGS} -D__MK20DX256__ -mcpu=cortex-m4")
    set(CFLAGS "${CFLAGS} -D__MK20DX256__ -mcpu=cortex-m4")
    set(LDSCRIPT mk20dx256.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 ${LDSCRIPT}")
elseif (TEENSY_VERSION EQUAL 32)
    set(CPPFLAGS "${CPPFLAGS} -D__MK20DX256__ -mcpu=cortex-m4")
    set(CFLAGS "${CFLAGS} -D__MK20DX256__ -mcpu=cortex-m4")
    set(LDSCRIPT mk20dx256.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 -T/teensyduino/bin/${LDSCRIPT}")
elseif (TEENSY_VERSION EQUAL LC)
    set(CPPFLAGS "${CPPFLAGS} -D__MKL26Z64__ -mcpu=cortex-m0plus")
    set(CFLAGS "${CFLAGS} -D__MKL26Z64__ -mcpu=cortex-m0plus")
    set(LDSCRIPT mkl26z64.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m0plus ${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM0l_math")
elseif (TEENSY_VERSION EQUAL 35)
    set(CPPFLAGS "${CPPFLAGS} -D__MK64FX512__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
    set(CFLAGS "${CFLAGS} -D__MK64FX512__ -mcpu=cortex-m4")
    set(LDSCRIPT mk64fx512.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 ${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM4lf_math")
elseif (TEENSY_VERSION EQUAL 36)
    message(STATUS "Compiling for Teensy 3.6")
    set(CPPFLAGS "${CPPFLAGS} -D__MK66FX1M0__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
    set(CFLAGS "${CFLAGS} -D__MK66FX1M0__ -mcpu=cortex-m4")
    set(LDSCRIPT mk66fx1m0.ld)
    set(LDFLAGS "${LDFLAGS} -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -T/teensyduino/bin/${LDSCRIPT}")
    set(LIBS "${LIBS} -larm_cortexM4lf_math")
endif ()



set(LDFLAGS "${LDFLAGS} ${LIBS}")
SET ( CMAKE_CXX_FLAGS ${CPPFLAGS} CACHE STRING "c++ compile flags" FORCE)
SET ( CMAKE_C_FLAGS ${CFLAGS} CACHE STRING "c compile flags" FORCE)
SET ( CMAKE_EXE_LINKER_FLAGS ${LDFLAGS} CACHE STRING "linker flags" FORCE)

add_subdirectory(libraries)
link_directories(libraries)
target_link_libraries(MAIN PUBLIC ${EXTRA_LIBS} )
target_include_directories(MAIN PUBLIC ${EXTRA_LIBS} )


add_custom_command(
  TARGET MAIN POST_BUILD
  COMMAND arm-none-eabi-objcopy -O ihex -R .eeprom MAIN main.hex
  VERBATIM)