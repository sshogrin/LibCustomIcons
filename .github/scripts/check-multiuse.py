import os
import re
from collections import defaultdict

ICONS_DIR = "icons"
TEXTURE_REGEX = re.compile(r'"(LibCustomIcons/icons/[^"]+\.dds)"')

# texture_path => list of (filename, line_number, full_line)
texture_references = defaultdict(list)

def scan_lua_file(filepath):
    with open(filepath, encoding="utf-8") as f:
        for i, line in enumerate(f, start=1):
            matches = TEXTURE_REGEX.findall(line)
            for texture in matches:
                if texture.startswith("LibCustomIcons/icons/animated/") or texture.startswith("LibCustomIcons/icons/flags/"):
                    continue
                texture_references[texture].append((filepath, i, line.strip()))

def main():
    for root, _, files in os.walk(ICONS_DIR):
        for file in files:
            if file.endswith(".lua"):
                scan_lua_file(os.path.join(root, file))

    found = False
    for texture, refs in texture_references.items():
        if len(refs) > 1:
            if not found:
                print("::warning:: ⚠️ Textures used multiple times:")
                found = True
            print(f"{texture}")
            for filepath, line_num, line_text in refs:
                print(f"  {filepath}:{line_num}: {line_text}")
            print()

if __name__ == "__main__":
    main()