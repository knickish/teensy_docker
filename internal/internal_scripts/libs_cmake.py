import os, sys
import json

# "example_library": {
#         "supported": [
#             "LC",
#             "30",
#             "31",
#             "32",
#             "35",
#             "36",
#             "40",
#             "41"
#         ],
#         "conflicts": []
#     },

conf_path = "/teensyduino/config.json"
libs_path = "/teensyduino/libraries"

def generate_lib_cmake(supported, conflicts, lib_name):
    ifstr = [f"(TEENSY_VERSION STREQUAL \"{x}\")" for x in supported]
    sep = " OR "
    ifstrProcessed = sep.join(ifstr)
    
    ret = f'\nIF({ifstrProcessed})'
    ret+= f'\nfile(GLOB {lib_name}_sources CONFIGURE_DEPENDS "*.h" "*.cpp" "*.c++" "*.c" "*.hpp" '
    ret+= '"src/*.h" "src/*.cpp" "src/*.c++" "src/*.c" "src/*.hpp" '
    ret+= '"utility/*.h" "utility/*.cpp" "utility/*.c++" "utility/*.c" "utility/*.hpp")'
    ret+= f"\nadd_library({lib_name} STATIC ${{{lib_name}_sources}})"
    ret+= f"\nset_target_properties({lib_name} PROPERTIES LINKER_LANGUAGE CXX)"
    ret+= f"\ntarget_include_directories({lib_name} PUBLIC ${{CMAKE_CURRENT_LIST_DIR}})"
    ret+= f"\nset(LIBNAME \"{lib_name}\" PARENT_SCOPE)"
    ret+= "\nENDIF()"
    return ret

def generate_lib_top_cmake(config):
    ret = """message(STATUS "${CMAKE_CURRENT_LIST_DIR}")
            \nSUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_LIST_DIR})
            \nFOREACH(subdir ${SUBDIRS})
            \n\tinclude_directories(${subdir})
            \n\tinclude_directories(${subdir}/src)
            \n\tinclude_directories(${subdir}/utility)
            \nendforeach()
            \nlist(APPEND EXTRA_LIBS_INNER)
            \nSUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_LIST_DIR})
            \nFOREACH(subdir ${SUBDIRS})
            \nset(LIBNAME "")
            \nmessage(STATUS "${subdir}")
            \n\tadd_subdirectory(${subdir})
            \nlist(APPEND EXTRA_LIBS_INNER ${LIBNAME};)
            \nendforeach()
            \nset(EXTRA_LIBS ${EXTRA_LIBS_INNER} PARENT_SCOPE)
            \nmessage(STATUS ${EXTRA_LIBS_INNER})"""
            
    return ret

def build(lib_dir):
    if not os.path.exists(lib_dir):
        return 1
    if not os.path.isdir(lib_dir):
        return 1
    config = None
    with open(conf_path, "r") as f:
        config = json.load(f)
    
    for direct in os.listdir(libs_path):
        if os.path.isdir(os.path.join(lib_dir, direct)):
            if direct in config:
                with open(os.path.join(lib_dir, direct, "CMakeLists.txt"), "w") as f:
                    f.write(generate_lib_cmake(config[direct]["supported"], config[direct]["conflicts"], direct))
    
    with open(os.path.join(lib_dir, "CMakeLists.txt"), "w") as f:
        f.write(generate_lib_top_cmake(config))
    
    return 0
    


if __name__ == "__main__":
    if not len(sys.argv)>=2:
        sys.exit(1)
    lib_dir = sys.argv[1]
    print(lib_dir)
    build(lib_dir)