CALL %~dp0\build_docker_container.bat

if not [%1]==[] goto program
echo
echo "Must use one of 30,31,32,35,35,40,41,LC as argument, exiting"
goto exit


:program
cd %~dp0..

CALL docker run -t -i --privileged ^
     -v /dev/bus/usb:/dev/bus/usb ^
     -v %CD%\src:/src ^
     -v %CD%\libs:/libs ^
     -v %CD%\artifacts\build:/teensyduino/build ^
     --env TEENSY_VERSION=%1 ^
      teensy_dev:latest

:exit