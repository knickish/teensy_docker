# Teensyduino Core Library
# http://www.pjrc.com/teensy/
# Copyright (c) 2017 PJRC.COM, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# 1. The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# 2. If the Software is incorporated into a build system that allows
# selection among a list of target devices, then similar target
# devices manufactured by PJRC.COM must be included in the list of
# target devices and selectable in the same manner.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# set your MCU type here, or make command line `make MCU=MK20DX256`
MCU=MK20DX256
#MCU=MKL26Z64
#MCU=MK64FX512
#MCU=MK66FX1M0

# make it lower case
LOWER_MCU := $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$(MCU)))))))))))))))))))))))))))
MCU_LD = $(LOWER_MCU).ld

# The name of your project (used to name the compiled .hex file)
TARGET = main
TEENSY = 36
# Those that specify a NO_ARDUINO environment variable will
# be able to use this Makefile with no Arduino dependency.
# Please note that if ARDUINOPATH was set, it will override
# the NO_ARDUINO behaviour.
ifndef NO_ARDUINO
# Path to your arduino installation
ARDUINOPATH ?= ../../../../..
endif

# configurable options
OPTIONS = -DF_CPU=48000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -DUSING_MAKEFILE

# options needed by many Arduino libraries to configure for Teensy 3.x
OPTIONS += -D__$(MCU)__ -DARDUINO=10805 -DTEENSYDUINO=144

# use "cortex-m4" for Teensy 3.x
# use "cortex-m0plus" for Teensy LC
CPUARCH = cortex-m4
#CPUARCH = cortex-m0plus


# Other Makefiles and project templates for Teensy 3.x:
#
# https://github.com/apmorton/teensy-template
# https://github.com/xxxajk/Arduino_Makefile_master
# https://github.com/JonHylands/uCee


#************************************************************************
# Location of Teensyduino utilities, Toolchain, and Arduino Libraries.
# To use this makefile without Arduino, copy the resources from these
# locations and edit the pathnames.  The rest of Arduino is not needed.
#************************************************************************

ifdef ARDUINOPATH

# path location for Teensy Loader, teensy_post_compile and teensy_reboot (on Linux)
TOOLSPATH = $(abspath $(ARDUINOPATH)/hardware/tools)

# path location for Arduino libraries (currently not used)
LIBRARYPATH = $(abspath $(ARDUINOPATH)/libraries)

# path location for the arm-none-eabi compiler
COMPILERPATH = $(abspath $(ARDUINOPATH)/hardware/tools/arm/bin)

else
# Default to the normal GNU/Linux compiler path if NO_ARDUINO
# and ARDUINOPATH was not set.
COMPILERPATH ?= /usr/bin

endif

#************************************************************************
# Settings below this point usually do not need to be edited
#************************************************************************

# CPPFLAGS = compiler options for C and C++
CPPFLAGS = -Wall -g -Os -mcpu=$(CPUARCH) -mthumb -MMD $(OPTIONS) -I.

# compiler options for C++ only
CXXFLAGS = -std=gnu++14 -felide-constructors -fno-exceptions -fno-rtti

# compiler options for C only
CFLAGS =

# linker options
LDFLAGS = -Os -Wl,--gc-sections,--defsym=__rtc_localtime=0 --specs=nano.specs -mcpu=$(CPUARCH) -mthumb -T$(MCU_LD)

# additional libraries to link
LIBS = -lm

# compiler options specific to teensy version
ifeq ($(TEENSY), 30)
    CPPFLAGS += -D__MK20DX128__ -mcpu=cortex-m4
    LDSCRIPT = $(COREPATH)/mk20dx128.ld
    LDFLAGS += -mcpu=cortex-m4 -T$(LDSCRIPT)
else ifeq ($(TEENSY), 31)
    CPPFLAGS += -D__MK20DX256__ -mcpu=cortex-m4
    LDSCRIPT = $(COREPATH)/mk20dx256.ld
    LDFLAGS += -mcpu=cortex-m4 -T$(LDSCRIPT)
else ifeq ($(TEENSY), 32)
    CPPFLAGS += -D__MK20DX256__ -mcpu=cortex-m4
    LDSCRIPT = $(COREPATH)/mk20dx256.ld
    LDFLAGS += -mcpu=cortex-m4 -T$(LDSCRIPT)
else ifeq ($(TEENSY), LC)
    CPPFLAGS += -D__MKL26Z64__ -mcpu=cortex-m0plus
    LDSCRIPT = $(COREPATH)/mkl26z64.ld
    LDFLAGS += -mcpu=cortex-m0plus -T$(LDSCRIPT)
    LIBS += -larm_cortexM0l_math
else ifeq ($(TEENSY), 35)
    CPPFLAGS += -D__MK64FX512__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
    LDSCRIPT = $(COREPATH)/mk64fx512.ld
    LDFLAGS += -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -T$(LDSCRIPT)
    LIBS += -larm_cortexM4lf_math
else ifeq ($(TEENSY), 36)
    CPPFLAGS += -D__MK66FX1M0__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
    LDSCRIPT = $(COREPATH)/mk66fx1m0.ld
    LDFLAGS += -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -T$(LDSCRIPT)
    LIBS += -larm_cortexM4lf_math
else
    $(error Invalid setting for TEENSY)
endif


# names for the compiler programs
CC = $(COMPILERPATH)/arm-none-eabi-gcc
CXX = $(COMPILERPATH)/arm-none-eabi-g++
OBJCOPY = $(COMPILERPATH)/arm-none-eabi-objcopy
SIZE = $(COMPILERPATH)/arm-none-eabi-size

# automatically create lists of the sources and objects
# TODO: this does not handle Arduino libraries yet...
LC_FILES := $(wildcard $(LIBRARYPATH)/*/*.c)
LCPP_FILES := $(wildcard $(LIBRARYPATH)/*/*.cpp)
C_FILES := $(wildcard *.c)
CPP_FILES := $(wildcard *.cpp)
OBJS := $(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o) $(LC_FILES:.c=.o) $(LCPP_FILES:.cpp=.o)


# the actual makefile rules (all .o files built by GNU make's default implicit rules)

all: $(TARGET).hex

%.o: %.c
	@echo -e "[CC]\t$<"
	@mkdir -p "$(dir $@)"
	@$(CC) $(CPPFLAGS) $(CFLAGS) $(L_INC) -o "$@" -c "$<"

%.o: %.cpp
	@echo -e "[CXX]\t$<"
	@mkdir -p "$(dir $@)"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(L_INC) -o "$@" -c "$<"

$(TARGET).elf: $(OBJS) $(MCU_LD)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.hex: %.elf
	$(SIZE) $<
	$(OBJCOPY) -O ihex -R .eeprom $< $@
ifneq (,$(wildcard $(TOOLSPATH)))
	# $(TOOLSPATH)/teensy_post_compile -file=$(basename $@) -path=$(shell pwd) -tools=$(TOOLSPATH)
	teensy_loader_cli --mcu=TEENSY36 -w -v $(basename $@).hex
endif

# compiler generated dependency info
-include $(OBJS:.o=.d)

clean:
	rm -f *.o *.d $(TARGET).elf $(TARGET).hex
