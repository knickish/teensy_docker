#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
./build_docker_container.sh

if [ $# -eq 0 ]
  then
     echo
     echo "Must use one of 30,31,32,35,35,40,41,LC as argument, exiting"
     exit 1
fi

docker run -t -i --privileged \
     -v /dev/bus/usb:/dev/bus/usb \
     -v ${DIR}/../src:/src \
     -v ${DIR}/../libs:/libs \
     -v ${DIR}/../artifacts/build:/teensyduino/build \
     -v ${DIR}/../artifacts/install:/teensyduino/install \
     --env TEENSY_VERSION=${1} \
     --env PROGRAM_ON_BUILD=1 \
      teensy_dev:latest