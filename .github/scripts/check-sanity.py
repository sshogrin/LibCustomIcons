import os
import re
import ast
import sys

ICONS_DIR = "icons"
ANIM_PATTERN = re.compile(r'^a\["([^"]+)"\]\s*=\s*(.+)$')
STATIC_PATTERN = re.compile(r'^s\["([^"]+)"\]\s*=\s*(.+)$')
MAX_FRAMES = 50

warnings = []
errors = []

def is_reference(value_str):
    return value_str.strip().startswith(("a[", "s["))

def is_valid_quoted_string(s):
    return s.startswith('"') and s.endswith('"') and len(s) > 2

def safe_parse_lua_table(lua_line):
    try:
        # Convert Lua table to Python list syntax
        line = lua_line.replace("{", "[").replace("}", "]")
        return ast.literal_eval(line)
    except Exception:
        return None

def main():
    for root, _, files in os.walk(ICONS_DIR):
        for file in files:
            if not file.endswith(".lua"):
                continue
            path = os.path.join(root, file)
            with open(path, encoding="utf-8") as f:
                for lineno, line in enumerate(f, start=1):
                    line = line.strip()

                    # Check animations
                    anim_match = ANIM_PATTERN.match(line)
                    if anim_match:
                        at_name, value_str = anim_match.groups()

                        if is_reference(value_str):
                            continue

                        data = safe_parse_lua_table(value_str)
                        if not isinstance(data, list) or len(data) != 4:
                            errors.append(f"Invalid animation table format:\t\t{path}:{lineno}: {at_name}")
                            continue

                        try:
                            _, width, height, fps = data
                            if width < 1 or height < 1 or fps < 1:
                                errors.append(f"Invalid dimensions: ({width} x {height} @ {fps}):\t{path}:{lineno}: {at_name}")
                            total_frames = width * height
                            if total_frames > MAX_FRAMES and not path.startswith("icons/animated"):
                                warnings.append(f"too many frames ({total_frames}):\t\t\t{path}:{lineno}: {at_name}")
                        except Exception:
                            errors.append(f"Non-integer values in animation table:\t{path}:{lineno}: {at_name}")
                        continue  # skip to next line

                    # Check static icons
                    static_match = STATIC_PATTERN.match(line)
                    if static_match:
                        at_name, value_str = static_match.groups()
                        if is_reference(value_str):
                            continue
                        if not is_valid_quoted_string(value_str):
                            errors.append(f"Invalid static texture path:\t\t{path}:{lineno}: {at_name}")
                        continue

    foundWarnings = len(warnings) > 0
    foundErrors = len(errors) > 0

    if foundWarnings:
        print("::warning:: ⚠️ Warnings:")
        for warn in warnings:
            print(warn)

    if foundErrors:
        print("::error:: ❌ Errors:")
        for err in errors:
            print(err)

    if foundErrors:
        sys.exit(1)
    if foundWarnings:
        sys.exit(0)

    print("::notice:: ✅ No errors in .lua files found")

if __name__ == "__main__":
    main()