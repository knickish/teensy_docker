import os
import json

def main():
    teensy_types = ["30","32", "31", "35", "36", "40", "41", "LC"]

    usage_dict = {}
    path = "/teensyduino/libraries"
    for direct in os.listdir(path):
        if os.path.isdir(os.path.join(path, direct)):
            if os.path.exists(os.path.join(path, direct, "config.json")):
                usage_dict[direct] = json.load(os.path.join(path, direct, "config.json"))
            else:
                usage_dict[direct] = {}
                usage_dict[direct]["supported"] = json_outer["teensy_types"]
                usage_dict[direct]["conflicts"] = []

    json_outer = usage_dict

    if os.path.exists("/teensyduino/config.json"):
        json_overrides = json.load("/teensyduino/config.json")
        for key, value in enumerate(json_overrides):
            json_outer[key] = json_overrides[key]

    with open("/teensyduino/config.json", "w") as f:
        json.dump(json_outer,f)
    

if __name__ == "__main__":
    main()
