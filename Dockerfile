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
    apt -y \
    install git \
    make \
    gcc \
    g++ \
    gcc-avr \
    binutils-avr \
    avr-libc \
    cmake

RUN apt -y \
    install unzip \
    libusb-dev \
    wget \
    xz-utils \
    libfontconfig1 \
    libxft-dev \
    rsync \
    tree \ 
    python3.8 \
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
RUN wget -q https://downloads.arduino.cc/arduino-1.8.13-linux64.tar.xz && \
    wget -q https://www.pjrc.com/teensy/td_153/TeensyduinoInstall.linux64 
    

# ------------------------------------------------------------------------------
# Configure teensyloader cli
WORKDIR /teensy_cli
RUN git clone -q https://github.com/PaulStoffregen/teensy_loader_cli && \
    cd teensy_loader_cli && \
    make && \
    cd rebootor && \
    make
ENV PATH="$PATH:/teensy_cli/teensy_loader_cli/"

# ------------------------------------------------------------------------------
# Check git setting
WORKDIR /teensyduino
RUN tar -xf arduino-1.8.13-linux64.tar.xz && \
    rm arduino-1.8.13-linux64.tar.xz && \
    chmod 755 TeensyduinoInstall.linux64 && \
    ./TeensyduinoInstall.linux64 --dir=/teensyduino/arduino-1.8.13 && \
    mkdir -p ./libraries && \
    mkdir -p ./cores && \
    mkdir -p ./src && \
    cp -r /teensyduino/arduino-1.8.13/hardware/teensy/avr/libraries/* ./libraries && \
    cp -r /teensyduino/arduino-1.8.13/hardware/teensy/avr/cores/* ./cores 

WORKDIR /teensyduino/libraries
RUN git clone https://github.com/adafruit/Adafruit_BusIO.git && \
    git clone https://github.com/adafruit/Adafruit-GFX-Library.git && \
    mkdir /src

WORKDIR /helper_scripts  
ADD internal_scripts/* /helper_scripts/
ENV PYTHONPATH="${PYTHONPATH}:/helper_scripts"

RUN /usr/bin/python3.8 -m lib_json_generator /teensyduino/libraries

CMD ["/bin/bash","/helper_scripts/entrypoint.sh"]