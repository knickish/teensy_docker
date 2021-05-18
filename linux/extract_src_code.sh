#!/bin/bash
docker rm teensy_dev_extract
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
./build_docker_container.sh
docker create --name teensy_dev_extract teensy_dev:latest
docker cp -a teensy_dev_extract:/teensyduino ${DIR}/../artifacts
docker rm teensy_dev_extract