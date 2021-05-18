#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


docker run -t -i --privileged \
     -v /dev/bus/usb:/dev/bus/usb \
     -v ${DIR}/../src:/src \
     -v ${DIR}/../libs:/libs \
     --entrypoint /bin/bash \
      teensy_dev:latest 