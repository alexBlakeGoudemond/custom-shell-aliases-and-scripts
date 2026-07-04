#!/usr/bin/env python3
"""
image-resize.py - Resize images using ImageMagick (Python port of image-size-converter.sh)
Usage: image-resize <imageSource> [-w width] [-h height] [-o outputName]

Resizes images to exact dimensions (not aspect ratio) using the 'magick' command.
"""

import argparse
import os
import sys
import subprocess
from pathlib import Path
from shutil import which

# Ensure UTF-8 stdout/stderr to avoid Windows console encoding errors when printing emojis
try:
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')
except Exception:
    try:
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
    except Exception:
        pass

ALIAS_VERSION = "1.0.0"
DEFAULT_WIDTH = 1280
DEFAULT_HEIGHT = 800


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def main(argv):
    parser = argparse.ArgumentParser(
        description="ImageResize - Resize images to exact dimensions using ImageMagick",
        prog="image-resize"
    )
    parser.add_argument("image_source", help="Path to source image file")
    parser.add_argument("-w", "--width", type=int, default=DEFAULT_WIDTH, help=f"Output width (default: {DEFAULT_WIDTH})")
    parser.add_argument("-o", "--output", dest="output_name", help="Custom output filename (optional)")
    parser.add_argument("--height", type=int, default=DEFAULT_HEIGHT, help=f"Output height (default: {DEFAULT_HEIGHT})")

    args = parser.parse_args(argv)

    print("")
    print(f"📷   ImageResize {ALIAS_VERSION} — Convert Image Dimensions with ImageMagick 🎨")
    print("───────────────────────────────────────────────────────────────")

    # Check ImageMagick
    magick = which("magick") or which("magick.exe")
    if not magick:
        eprint("❌ Error: ImageMagick command 'magick' is not installed.")
        sys.exit(1)

    # Resolve source image
    image_source = Path(args.image_source).resolve()
    if not image_source.exists():
        eprint("❌ Error: File does not exist:")
        eprint(f"  {image_source}")
        sys.exit(1)

    print(f"✅ Found source image: {image_source}")

    # Determine output filename
    source_dir = image_source.parent
    source_file = image_source.name
    source_name = image_source.stem
    source_ext = image_source.suffix.lstrip('.')

    suffix = f"-resized-{args.width}-{args.height}"

    if args.output_name:
        custom_base = Path(args.output_name).name
        custom_name_only = Path(custom_base).stem
        output_file = f"{custom_name_only}{suffix}.{source_ext}"
    else:
        output_file = f"{source_name}{suffix}.{source_ext}"

    output_path = source_dir / output_file

    print("🔃 Resizing image to these exact dimensions (not aspect ratio)...")
    print(f"  Source : {image_source}")
    print(f"  Width  : {args.width}")
    print(f"  Height : {args.height}")
    print(f"  Output : {output_path}")

    try:
        subprocess.run([
            magick,
            str(image_source),
            "-resize",
            f"{args.width}x{args.height}!",
            str(output_path)
        ], check=True)
    except subprocess.CalledProcessError as e:
        eprint(f"❌ ImageMagick failed: {e}")
        sys.exit(1)

    print("")
    print("✅ Done!")
    print("Saved resized image to:")
    print(f"  {output_path}")
    print("")
    print("📷   ImageResize finished 🎨")
    print("───────────────────────────────────────────────────────────────")


if __name__ == "__main__":
    main(sys.argv[1:])
