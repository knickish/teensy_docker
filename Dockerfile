# ------------------------------------------------------------------------------
# Pull base image
FROM ubuntu:20.04

# ------------------------------------------------------------------------------
# Arguments
ARG WORKDIR=/root

# ------------------------------------------------------------------------------
# Install tools via apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update && \
    apt -y install \
    git \
    make \
    gcc \
    g++ \
    gcc-avr \
    binutils-avr \
    avr-libc \
    cmake \
    unzip \
    libusb-dev \
    wget \
    xz-utils \
    libfontconfig1 \
    libxft-dev \
    python3.8 \
    vim \
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
RUN wget -q https://downloads.arduino.cc/arduino-1.8.15-linux64.tar.xz && \
    wget -q https://www.pjrc.com/teensy/td_154-beta10/TeensyduinoInstall.linux64

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
RUN tar -xf arduino-1.8.15-linux64.tar.xz && \
    rm arduino-1.8.15-linux64.tar.xz && \
    chmod 755 TeensyduinoInstall.linux64 && \
    ./TeensyduinoInstall.linux64 --dir=/teensyduino/arduino-1.8.15 && \
    mkdir -p ./libraries && \
    mkdir -p ./cores && \
    mkdir -p ./src && \
    cp -r /teensyduino/arduino-1.8.15/hardware/teensy/avr/libraries/* ./libraries && \
    cp -r /teensyduino/arduino-1.8.15/hardware/teensy/avr/cores/* ./cores 

# some of the libraries used for many adafruit products
WORKDIR /teensyduino/libraries
RUN git clone https://github.com/adafruit/Adafruit_BusIO.git && \
    git clone https://github.com/adafruit/Adafruit-GFX-Library.git && \
    mkdir /src

WORKDIR /teensyduino/bin
RUN cp -r /teensyduino/arduino-1.8.15/hardware/tools/arm/bin/* . && \
    cp -r /teensyduino/arduino-1.8.15/hardware/tools/arm/lib/gcc/arm-none-eabi/5.4.1/* . && \
    cp -u /teensyduino/cores/teensy3/*.ld . && \
    cp -u /teensyduino/cores/teensy4/*.ld . && \
    mkdir -p /teensyduino/lib/gcc && \
    cp -r /teensyduino/arduino-1.8.15/hardware/tools/arm/lib/gcc/arm-none-eabi/5.4.1/* /teensyduino/lib/gcc
    
WORKDIR /teensyduino/include
RUN cp -r /teensyduino/arduino-1.8.15/hardware/tools/arm/arm-none-eabi/include/* . && \
    cp -r /teensyduino/arduino-1.8.15/hardware/tools/arm/arm-none-eabi/lib/armv7e-m/* . && \
    cp /teensyduino/arduino-1.8.15/hardware/tools/arm/arm-none-eabi/lib/nano.specs . && \
    cp /teensyduino/arduino-1.8.15/hardware/tools/arm/arm-none-eabi/lib/lib* . && \
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
RUN rm -rf ./arduino-1.8.15 && \
    rm TeensyduinoInstall.linux64

CMD ["/bin/bash","/helper_scripts/entrypoint.sh"]