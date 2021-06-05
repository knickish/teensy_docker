## Teensy Build Env

This dockerfile and associated scripts are an attempt to create a more straightforward and standardized build environment for Teensy boards, without needing to use the graphical loader or the arduino environment. Linux and Windows are supported.

To use, simply install docker, clone the repo, and run the OS-appropriate program script. Drop source cpp/h files in the src folder, and any extra library folders can be cloned into the libs folder. (Windows cannot pass USB devices to docker, so the hex file must be manually flashed. It is stored in ./artifacts/install after compilation)

To build your code and program the device, run the program.sh script with one of 30,31,32,35,35,40, or 41 as the argument, depending on your teensy board. The script will pause at the end until a teensy board is plugged in and the button is pressed to allow programming.


 ![ Alt text](https://i.imgur.com/KcN6Hfq.gif)  ![](https://i.imgur.com/KcN6Hfq.gif)

Pull requests are welcome if bugs are encountered, I've tested on a 3.2, 3.6, 4.0, and 4.1 so far with at least basic programs. 