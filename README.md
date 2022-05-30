## Teensy Build Env

This dockerfile and associated scripts are an attempt to create a more straightforward and standardized build environment for Teensy boards, without needing to use the graphical loader or the arduino environment. Linux and Windows are supported.

To set up, simply install docker and clone the repo, then run the build-docker-container script to make the container and the folders necessary for building. Drop source cpp/h files in the src folder, and any extra library folders can be cloned into the libs folder. Make sure Arduino.h has been included and a main defined. 

To build your code and program the device, run the program script with one of 30,31,32,35,35,40, or 41 as the argument, depending on your teensy board. The script will pause at the end until a teensy board is plugged in and the button is pressed to allow programming. (Windows cannot pass USB devices to docker, so the hex file must be manually flashed. It is stored in ./artifacts/install after compilation.)


## Example Usage
Step 1:
Place code in src folder

Step 2:
Navigate to OS-appropriate script directory

Step 3:

- Linux:
    >$ ./program.sh 40

- Windows:
    >.\program.bat 40
### Real-Time Full Build/Programming (~30s)
![](https://i.imgur.com/VLQ9xak.gif)

### Real-Time Rebuild/Programming (~5s)
![](https://i.imgur.com/NhB57Mc.gif)

Pull requests are welcome if bugs are encountered, I've tested on a 3.2, 3.6, 4.0, and 4.1 so far with at least basic programs. 
