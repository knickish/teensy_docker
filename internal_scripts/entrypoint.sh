#!/bin/bash

cd /teensyduino 
cp -ru /src/* /teensyduino/src 
cp -ru /libs/* /teensyduino/libraries 
/usr/bin/python3.8 -m lib_json_generator /teensyduino/libraries
/usr/bin/python3.8 -m libs_cmake /teensyduino/libraries
rm -rf /teensyduino/build/*
export CC=/teensyduino/bin
export CXX=/teensyduino/bin
export LIBRARY_PATH=/teensyduino/include:$LIBRARY_PATH
find . | grep ble_system.h
cmake -DCMAKE_TOOLCHAIN_FILE=/teensyduino/teensy_toolchain.cmake \
     -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON  -DCMAKE_AR=/usr/bin/ar \
      \
     -B /teensyduino/build -S . 

# find -L . -type l | grep liblto_plugin.so
# env | grep LD_LIBRARY_PATH
cd /teensyduino/build

make 
/bin/bash