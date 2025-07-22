import os
import sys

ICONS_DIR = "icons"
ADDON_FILE = "LibCustomIcons.addon"

def get_lua_files_from_folder(folder):
    return sorted([
        f for f in os.listdir(folder)
        if f.endswith(".lua") and os.path.isfile(os.path.join(folder, f))
    ])

def get_listed_icon_files_from_addon(addon_path):
    listed_files = []
    with open(addon_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("icons/") and line.endswith(".lua"):
                listed_files.append(line.split("/")[-1])
    return sorted(listed_files)

def main():
    local_icons = get_lua_files_from_folder(ICONS_DIR)
    listed_icons = get_listed_icon_files_from_addon(ADDON_FILE)

    missing_in_addon = sorted(set(local_icons) - set(listed_icons))
    extra_in_addon = sorted(set(listed_icons) - set(local_icons))

    if not missing_in_addon and not extra_in_addon:
        print("::notice:: ✅ All icon .lua files are included in LibCustomIcons.addon")
        sys.exit(0)
    else:
        if missing_in_addon:
            print("::error:: ❌ Missing in .addon file:")
            for name in missing_in_addon:
                print(f"  icons/{name}")
            sys.exit(1)
        if extra_in_addon:
            print("::warning:: ❌ Listed in .addon file but missing on disk:")
            for name in extra_in_addon:
                print(f"  icons/{name}")
            sys.exit(1)

if __name__ == "__main__":
    main()