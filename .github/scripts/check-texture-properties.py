import os
import re
import sys
import struct

# Constants
ROOT_DIR = "."  # We are running from LibCustomIcons/
MAX_STATIC_SIZE = 128

# Warnings and errors will be collected here
warnings = []
errors = []

# Cache DDS sizes to avoid reading the same file multiple times
dds_cache = {}


def find_dds_size(path):
    """Reads a DDS file and returns its width and height."""
    if path in dds_cache:
        return dds_cache[path]
    try:
        with open(path, "rb") as f:
            header = f.read(128)
            if len(header) != 128 or header[:4] != b"DDS ":
                return None
            height, width = struct.unpack_from("<II", header, offset=12)
            dds_cache[path] = (width, height)
            return width, height
    except Exception:
        return None


def parse_lua_file(filepath):
    """Parses a Lua file and extracts texture references from static and animated icon tables."""
    with open(filepath, "r", encoding="utf-8") as f:
        for lineno, line in enumerate(f, 1):
            # Static icons: s["@User"] = "icons/foo.dds"
            static_match = re.match(r'\s*s\["(@[^"]+)"\]\s*=\s*"([^"]+)"', line)
            if static_match:
                name, dds_path = static_match.groups()
                check_static_icon(dds_path, name, filepath, lineno)
                continue

            # Animated icons: a["@User"] = {"path.dds", 4, 4, 25}
            anim_match = re.match(r'\s*a\["(@[^"]+)"\]\s*=\s*{(.*?)}', line)
            if anim_match:
                name, values = anim_match.groups()
                parts = [p.strip().strip('"') for p in values.split(",")]
                if len(parts) >= 4:
                    dds_path, w, h, fps = parts[:4]
                    try:
                        w, h, fps = int(w), int(h), int(fps)
                        check_animated_icon(dds_path, name, filepath, lineno, w, h, fps)
                    except ValueError:
                        continue


def check_static_icon(dds_path, name, lua_file, line):
    """Checks static icon dimensions."""
    rel_path = dds_path.replace("LibCustomIcons/", "").lstrip("/")
    full_path = os.path.join(ROOT_DIR, rel_path).replace("/", os.sep)
    size = find_dds_size(full_path)
    if size is None:
        if "esoui/" in dds_path:
            return
        errors.append(f"{lua_file}:{line} | {name}: File not found or unreadable: {dds_path}")
        return
    width, height = size
    if width != height:
        errors.append(f"{lua_file}:{line} | {name}: Not square ({width}x{height})")
    if width > MAX_STATIC_SIZE or height > MAX_STATIC_SIZE:
        warnings.append(f"{lua_file}:{line} | {name}: Size too large ({width}x{height})")
    if width % 2 != 0 or height % 2 != 0:
        errors.append(f"{lua_file}:{line} | {name}: Size is not multiple of 8 ({width}x{height})")


def check_animated_icon(dds_path, name, lua_file, line, cols, rows, fps):
    """Checks animated icon dimensions against declared layout."""
    rel_path = dds_path.replace("LibCustomIcons/", "").lstrip("/")
    full_path = os.path.join(ROOT_DIR, rel_path).replace("/", os.sep)
    size = find_dds_size(full_path)
    if size is None:
        errors.append(f"{lua_file}:{line} | {name}: File not found or unreadable: {dds_path}")
        return
    width, height = size
    if width % cols != 0 or height % rows != 0:
        errors.append(f"{lua_file}:{line} | {name}: Texture size {width}x{height} not divisible by {cols}x{rows} frames")
    if width % 2 != 0 or height % 2 != 0:
        errors.append(f"{lua_file}:{line} | {name}: Size is not multiple of 8 ({width}x{height})")


def main():
    for root, _, files in os.walk(ROOT_DIR):
        for file in files:
            if file.endswith(".lua"):
                parse_lua_file(os.path.join(root, file))

    print(f"\nScanned {len(dds_cache)} texture(s)")
    print(f"{len(warnings)} warning(s), {len(errors)} error(s)")

    if warnings:
        print("::warning:: Warnings:")
        for w in warnings:
            print(w)

    if errors:
        print("::error:: Errors:")
        for e in errors:
            print(e)

    if errors:
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
