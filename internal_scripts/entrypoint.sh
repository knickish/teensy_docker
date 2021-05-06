#!/bin/bash

cd /teensyduino 
cp -ru /src/* /teensyduino/src 
cp -ru /libs/* /teensyduino/libraries 
/usr/bin/python3.8 -m libs_cmake /teensyduino/libraries
tree -f -L 2 /teensyduino/libraries/