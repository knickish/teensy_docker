cmake_minimum_required(VERSION 3.0)
project(TEENSY)
include(macros.cmake)
# define library version (update: apparently you can also do it in project()!)
set(MY_LIBRARY_VERSION_MAJOR 1 CACHE STRING "major version" FORCE)
set(MY_LIBRARY_VERSION_MINOR 0 CACHE STRING "minor version" FORCE)
set(MY_LIBRARY_VERSION ${MY_LIBRARY_VERSION_MAJOR}.${MY_LIBRARY_VERSION_MINOR} CACHE STRING "version" FORCE)

# some options
# option(MY_LIBRARY_USE_FANCY_NEW_CLASS "whether or not to use fancy new class" ON)
# option(MY_LIBRARY_DEBUG_MODE "whether or not debug mode is activated" OFF)
if ( TEENSY_VERSION )
    if TEENSY_VER


# add subdirectories
add_subdirectory(src)
add_subdirectory(cores)
add_subdirectory(libraries)
