include(CMakeForceCompiler)

set(CMAKE_SYSTEM_NAME Generic) # Or name of your OS if you have one
set(CMAKE_SYSTEM_PROCESSOR arm) # Or whatever
set(CMAKE_CROSSCOMPILING 1)

set(CMAKE_C_COMPILER arm-none-eabi-gcc) 
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY) # Required to make the previous line work for a target that requires a custom linker file