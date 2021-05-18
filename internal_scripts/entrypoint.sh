#!/bin/bash

export TEENSY_VERSION=32
cd /teensyduino 
cp -ru /src/* /teensyduino/src 
cp -ru /libs/* /teensyduino/libraries 
/usr/bin/python3.8 -m lib_json_generator /teensyduino/libraries
/usr/bin/python3.8 -m libs_cmake /teensyduino/libraries
export CC=/teensyduino/bin
export CXX=/teensyduino/bin
export LIBRARY_PATH=/teensyduino/include:$LIBRARY_PATH
find . | grep ble_system.h
cmake -DCMAKE_TOOLCHAIN_FILE=/teensyduino/teensy_toolchain.cmake \
     -DCMAKE_AR=/usr/bin/ar -DTEENSY_VERSION:INTERNAL=${TEENSY_VERSION} \
     -B /teensyduino/build -S . 

cd /teensyduino/build
make -j4
teensy_loader_cli --mcu=TEENSY${TEENSY_VERSION} -w -v main.hex