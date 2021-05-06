#!/bin/bash

cd /teensyduino
rm main.c* 
cp -ru /src/* /teensyduino/src 
cp -ru /libs/* /teensyduino/libraries 
tree -f -L 4 /teensyduino