#!/bin/bash
docker rm extract
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
./build.sh
docker create --name extract teensy_dev:latest
docker cp -a extract:/teensyduino ${DIR}/arduino_src
docker rm extract