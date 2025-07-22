import os
import sys

# Directories
LUA_DIR = "icons"
TEXTURE_DIR = "icons"

# Collect all lines from .lua files
lua_lines = []
for root, _, files in os.walk(LUA_DIR):
    for file in files:
        if file.endswith(".lua"):
            with open(os.path.join(root, file), encoding="utf-8") as f:
                lua_lines.extend(line.strip() for line in f)

# Collect all .dds files and check for usage
orphaned_dds = []

for root, _, files in os.walk(TEXTURE_DIR):
    for file in files:
        if file.endswith(".dds"):
            full_path = os.path.join(root, file)
            relative_path = os.path.relpath(full_path, LUA_DIR).replace("\\", "/")
            just_name = file

            # Check if the file is referenced anywhere in the .lua lines
            found = any(relative_path in line or just_name in line for line in lua_lines)

            if not found:
                orphaned_dds.append(relative_path)

# Output results
if orphaned_dds:
    print("::warning:: ⚠️ Orphaned .dds files found:")
    for path in orphaned_dds:
        print(f" - {path}")
    sys.exit(0)
else:
    print("::notice:: ✅ No orphaned .dds files found.")
    sys.exit(0)