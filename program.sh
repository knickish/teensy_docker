#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
./build.sh
docker create --name extract teensy_dev
docker cp -a extract:/teensyduino/arduino-1.8.13/hardware/teensy/avr/cores/teensy3 ${DIR}/arduino_src
docker run -t -i --privileged \
     -v /dev/bus/usb:/dev/bus/usb \
     -v ${DIR}/src:/src \
      teensy_dev:latest
