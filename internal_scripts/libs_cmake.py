import os, sys
import subprocess

conf_path = "/teensyduino/config.json"
libs_path = "/teensyduino/libraries"

def generate_lib_cmake(supported, conflicts):
    return ""

def generate_lib_top_cmake(config):
    return ""

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
                    f.write(generate_lib_cmake(config[direct][supported], config[direct][conflicts]))
    
    with open(os.path.join(lib_dir, "CMakeLists.txt"), "w") as f:
        f.write(generate_lib_top_cmake(config))
    
    return 0
    


if __name__ == "__main__":
    if not len(sys.argv)>=2:
        sys.exit(1)
    lib_dir = sys.argv[1]
    sys.exit(build_all(build_top_dir, lib_dir))