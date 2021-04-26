#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
./build.sh
docker run -t -i --privileged \
     -v /dev/bus/usb:/dev/bus/usb \
     -v ${DIR}/src:/src \
     -v ${DIR}/adruino_src:/teensyduino/arduino-1.8.13/hardware/teensy/avr/cores/teensy3 \
      teensy_dev
