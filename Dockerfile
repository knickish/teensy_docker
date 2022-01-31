# ------------------------------------------------------------------------------
# Pull base image
FROM ubuntu:20.04

# ------------------------------------------------------------------------------
# Arguments
ARG WORKDIR=/root

ENV DOCKER_ARDUINO_VERSION=arduino-1.8.19
ENV DOCKER_TEENSY_TD_VERSION=td_156
# ------------------------------------------------------------------------------
# Install tools via apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update && \
    apt -y install \
    avr-libc \
    binutils-avr \
    cmake \
    g++ \
    gcc \
    gcc-avr \
    git \
    libfontconfig1 \
    libusb-dev \
    libxft-dev \
    make \
    python3.8 \
    unzip \
    vim \
    wget \
    xz-utils \
    && apt clean && rm -rf /var/lib/apt/lists

RUN mkdir -p /etc/udev/rules.d/  && \  
    echo    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1" \
            ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789a]*", ENV{MTP_NO_PROBE}="1" \
            KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", MODE:="0666", RUN:="/bin/stty -F /dev/%k raw -echo" \
            KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", MODE:="0666" \
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", MODE:="0666" >> /etc/udev/rules.d/00-teensy.rules
# ------------------------------------------------------------------------------
# Download large files
WORKDIR /teensyduino
RUN wget -q https://downloads.arduino.cc/${DOCKER_ARDUINO_VERSION}-linux64.tar.xz && \
    wget -q https://www.pjrc.com/teensy/${DOCKER_TEENSY_TD_VERSION}/TeensyduinoInstall.linux64

# ------------------------------------------------------------------------------
# Configure teensyloader cli
WORKDIR /teensy_cli
RUN git clone -q https://github.com/PaulStoffregen/teensy_loader_cli && \
    cd teensy_loader_cli && \
    make && \
    cd rebootor && \
    make
ENV PATH="$PATH:/teensy_cli/teensy_loader_cli/"

WORKDIR /teensyduino
RUN tar -xf ${DOCKER_ARDUINO_VERSION}-linux64.tar.xz && \
    rm ${DOCKER_ARDUINO_VERSION}-linux64.tar.xz && \
    chmod 755 TeensyduinoInstall.linux64 && \
    ./TeensyduinoInstall.linux64 --dir=/teensyduino/${DOCKER_ARDUINO_VERSION} && \
    mkdir -p ./libraries && \
    mkdir -p ./cores && \
    mkdir -p ./src && \
    cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/teensy/avr/libraries/* ./libraries && \
    cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/teensy/avr/cores/* ./cores 

# some of the libraries used for many adafruit products
WORKDIR /teensyduino/libraries
RUN  \ 
    git clone https://github.com/adafruit/Adafruit_BusIO.git && \
    git clone https://github.com/adafruit/Adafruit-GFX-Library.git && \
    mkdir /src

WORKDIR /teensyduino/bin
RUN cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/bin/* . && \
    cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/lib/gcc/arm-none-eabi/5.4.1/* . && \
    cp -u /teensyduino/cores/teensy3/*.ld . && \
    cp -u /teensyduino/cores/teensy4/*.ld . && \
    mkdir -p /teensyduino/lib/gcc && \
    cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/lib/gcc/arm-none-eabi/5.4.1/* /teensyduino/lib/gcc
    
WORKDIR /teensyduino/include
RUN cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/arm-none-eabi/include/* . && \
    cp -r /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/arm-none-eabi/lib/armv7e-m/* . && \
    cp /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/arm-none-eabi/lib/nano.specs . && \
    cp /teensyduino/${DOCKER_ARDUINO_VERSION}/hardware/tools/arm/arm-none-eabi/lib/lib* . && \
    mv crt0.o /teensyduino/lib/gcc
    
ENV PATH="/teensyduino/bin:/teensyduino/include:/teensyduino/bin/plugin/include:$PATH"

WORKDIR /teensyduino
RUN mkdir -p /teensyduino/install && \
    mkdir -p /teensyduino/build
ADD internal/CMake/project_root/* /teensyduino/
ADD internal/CMake/toolchain/* /teensyduino/
ADD config.json /teensyduino/
ADD internal/CMake/select_all/CMakeLists.txt /teensyduino/cores/teensy3
ADD internal/CMake/select_all/CMakeLists.txt /teensyduino/cores/teensy4
ADD internal/CMake/select_all/CMakeLists.txt /teensyduino/src
RUN rm /teensyduino/cores/teensy3/main.* && \
    rm /teensyduino/cores/teensy4/main.* && \
    rm /teensyduino/cores/teensy4/Blink.cc
    
WORKDIR /helper_scripts  
ADD internal/internal_scripts/* /helper_scripts/
ENV PYTHONPATH="${PYTHONPATH}:/helper_scripts"

RUN cp /teensyduino/bin/arm-none-eabi-as /usr/bin/as

#remove large files
WORKDIR /teensyduino
RUN rm -rf ./${DOCKER_ARDUINO_VERSION} && \
    rm TeensyduinoInstall.linux64

CMD ["/bin/bash","/helper_scripts/entrypoint.sh"]
