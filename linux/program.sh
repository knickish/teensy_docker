#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
./build_docker_container.sh
docker run -t -i --privileged \
     -v /dev/bus/usb:/dev/bus/usb \
     -v ${DIR}/../src:/src \
     -v ${DIR}/../libs:/libs \
     -v ${DIR}/../artifacts/build:/teensyduino/build \
      teensy_dev:latest