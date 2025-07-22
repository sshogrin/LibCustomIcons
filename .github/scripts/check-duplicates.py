import os
import sys
import re
from collections import defaultdict

# Directory with the Lua files (non-recursive, can be made recursive)
LUA_DIR = "icons"

# Regex pattern to match lines like: n["@m00nyONE"] =
pattern = re.compile(r'(?P<table>[nsa])\s*\[\s*"(?P<name>@[^"]+)"\s*\]\s*=')

# Global tracker: {table: {name: [file1, file2, ...]}}
global_seen = defaultdict(lambda: defaultdict(list))

def check_file(filepath):
    with open(filepath, encoding="utf-8") as f:
        for line in f:
            match = pattern.search(line)
            if match:
                table = match.group("table")
                name = match.group("name")
                global_seen[table][name].append(filepath)

def main():
    for file in os.listdir(LUA_DIR):
        if file.endswith(".lua"):
            full_path = os.path.join(LUA_DIR, file)
            check_file(full_path)

    duplicates_found = False
    for table, names in global_seen.items():
        for name, files in names.items():
            if len(files) > 1:
                if not duplicates_found:
                    print("::error:: ❌ Duplicates found across files:")
                    duplicates_found = True
                print(f"  {table}[\"{name}\"] appears in:")
                for file in files:
                    print(f"    - {file}")

    if not duplicates_found:
        print("::notice:: ✅ No duplicates found across files.")
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()