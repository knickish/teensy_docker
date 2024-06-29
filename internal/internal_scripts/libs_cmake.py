import os, sys
import json
from typing import Optional, List

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
#         "subdirs": []
#     },

conf_path = "/teensyduino/config.json"
libs_path = "/teensyduino/libraries"

def generate_lib_cmake(supported, conflicts, subdirs: Optional[List[str]], lib_name):
    ifstrs = [f"(TEENSY_VERSION STREQUAL \"{x}\")" for x in supported]
    
    ret = f'\nIF({" OR ".join(ifstrs)})'
    ret+= f'\nfile(GLOB {lib_name}_sources CONFIGURE_DEPENDS "*.h" "*.cpp" "*.c++" "*.c" "*.hpp" "*.S" '
    ret+= '"src/*.h" "src/*.cpp" "src/*.c++" "src/*.c" "src/*.hpp" "src/*.S" '
    ret+= '"utility/*.h" "utility/*.cpp" "utility/*.c++" "utility/*.c" "utility/*.hpp" "utility/*.S" '
    ret+= '"src/utility/*.h" "src/utility/*.cpp" "src/utility/*.c++" "src/utility/*.c" "src/utility/*.hpp" "src/utility/*.S")'
    ret+= f"\nadd_library({lib_name} STATIC ${{{lib_name}_sources}})"
    ret+= f"\nset_target_properties({lib_name} PROPERTIES LINKER_LANGUAGE CXX)"
    ret+= f"\ntarget_include_directories({lib_name} PUBLIC ${{CMAKE_CURRENT_LIST_DIR}})\n"
    if subdirs:
        ret+= "\n".join([f"target_include_directories({lib_name} PUBLIC ${{CMAKE_CURRENT_LIST_DIR}}/src/{subdir})" for subdir in subdirs])
    ret+= f"\nset(LIBNAME \"{lib_name}\" PARENT_SCOPE)"
    ret+= "\nENDIF()"
    return ret

def generate_lib_top_cmake(config):
    ret = """message(STATUS "${CMAKE_CURRENT_LIST_DIR}")
            \nSUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_LIST_DIR})
            \nlist(APPEND EXTRA_INCLUDE_LIBS_INNER)
            \nlist(APPEND EXTRA_LINK_LIBS_INNER)
            \nFOREACH(subdir ${SUBDIRS})
            \n\tinclude_directories(${CMAKE_CURRENT_LIST_DIR}/${subdir})
            \n
            \n\tIF(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${subdir}/src" AND IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${subdir}/src")
            \n\t\tmessage(STATUS "${subdir}/src")
            \n\t\tinclude_directories(${CMAKE_CURRENT_LIST_DIR}/${subdir}/src)
            \n\t\tlist(APPEND EXTRA_INCLUDE_LIBS_INNER ${CMAKE_CURRENT_LIST_DIR}/${subdir}/src;)
            \n\tENDIF()
            \n
            \n\tIF(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${subdir}/utility" AND IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${subdir}/utility")
            \n\t\tmessage(STATUS "${subdir}/utility")
            \n\t\tinclude_directories(${CMAKE_CURRENT_LIST_DIR}/${subdir}/utility)
            \n\t\tlist(APPEND EXTRA_INCLUDE_LIBS_INNER ${CMAKE_CURRENT_LIST_DIR}/${subdir}/utility;)
            \n\tENDIF()
            \n
            \n\tIF(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${subdir}/src/utility" AND IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${subdir}/src/utility")
            \n\t\tmessage(STATUS "${subdir}/src/utility")
            \n\t\tinclude_directories(${CMAKE_CURRENT_LIST_DIR}/${subdir}/src/utility)
            \n\t\tlist(APPEND EXTRA_INCLUDE_LIBS_INNER ${CMAKE_CURRENT_LIST_DIR}/${subdir}/src/utility;)
            \n\tENDIF()
            \nendforeach()

            \nSUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_LIST_DIR})
            \nFOREACH(subdir ${SUBDIRS})
            \nset(LIBNAME "")
            \nmessage(STATUS "${subdir}")
            \n\tadd_subdirectory(${subdir})
            \nlist(APPEND EXTRA_INCLUDE_LIBS_INNER ${LIBNAME};)
            \nlist(APPEND EXTRA_LINK_LIBS_INNER ${LIBNAME};)
            \nendforeach()
            \nset(EXTRA_INCLUDE_LIBS ${EXTRA_INCLUDE_LIBS_INNER} PARENT_SCOPE)
            \nset(EXTRA_LINK_LIBS ${EXTRA_LINK_LIBS_INNER} PARENT_SCOPE)
            \nmessage(STATUS ${EXTRA_INCLUDE_LIBS_INNER})"""
            
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
                subdirs = None
                if "subdirs" in config[direct]:
                    subdirs = config[direct]["subdirs"]
                with open(os.path.join(lib_dir, direct, "CMakeLists.txt"), "w") as f:
                    f.write(generate_lib_cmake(config[direct]["supported"], config[direct]["conflicts"], subdirs, direct))
    
    with open(os.path.join(lib_dir, "CMakeLists.txt"), "w") as f:
        f.write(generate_lib_top_cmake(config))
    
    return 0
    


if __name__ == "__main__":
    if not len(sys.argv)>=2:
        sys.exit(1)
    lib_dir = sys.argv[1]
    print(lib_dir)
    build(lib_dir)