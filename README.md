## Teensy Build Env

This dockerfile and associated scripts are an attempt to create a more straightforward and standardized build environment for Teensy boards, without needing to use the graphical loader or the arduino environment. Only linux is supported for now, but planning on Windows support soon. 

To use, simply install docker, clone the repo, and run the build script. Drop source cpp/h files in the src folder, and any extra libraries can be cloned into the libs folder. 

To build your code and program the device, run the program.sh script with one of 30,31,32,35,35,40, or 41 as the argument, depending on your teensy board. The script will pause at the end until a teensy board is plugged in and the button is pressed to allow programming.

Pull requests are welcome, I only have a 3.2 and a 3.6 so I havent been able to test all of the configurations myself. 