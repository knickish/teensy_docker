docker rm teensy_dev_extract
cd %~dp0
CALL .\build_docker_container.bat
CALL docker create --name teensy_dev_extract teensy_dev:latest
CALL docker cp -a teensy_dev_extract:/teensyduino %CD%\..\artifacts
CALL docker rm teensy_dev_extract