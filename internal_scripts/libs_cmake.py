import os, sys
import subprocess

conf_path = "/teensyduino/config.json"

def build(lib_dir):
    if not os.path.exists(lib_dir):
        return 1
    if not os.path.isdir(lib_dir):
        return 1
    

    
    return 0
    


if __name__ == "__main__":
    if not len(sys.argv)>=2:
        sys.exit(1)
    lib_dir = sys.argv[1]
    sys.exit(build_all(build_top_dir, lib_dir))