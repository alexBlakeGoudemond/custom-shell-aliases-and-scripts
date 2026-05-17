#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# image-size-converter: Convert image dimensions quickly using tool `magick` (ImageMagick)
# Usage: image-resize <imageSource> [-w width] [-h height] [-o outputName]
#
# For fun, we named this little tool as `image-resize`
# --------------------------------------------------------------------------------------------------------

set -e  # exit if anything fails

ALIAS_VERSION="1.0.0"

echo ""
echo "📷   ImageResize $ALIAS_VERSION — Convert Image Dimensions with ImageMagick 🎨"
echo "───────────────────────────────────────────────────────────────"

set -e

# ----------------------------------------
# Defaults
# ----------------------------------------
DEFAULT_WIDTH=1280
DEFAULT_HEIGHT=800

# ----------------------------------------
# Helpers
# ----------------------------------------
print_usage() {
    echo ""
    echo "image-resize: Resize an image using ImageMagick"
    echo ""
    echo "Usage:"
    echo "  image-resize <imageSource> [-w width] [-h height] [-o outputName]"
    echo ""
    echo "Examples:"
    echo "  image-resize photo.png"
    echo "  image-resize photo.png -w 1920 -h 1080"
    echo "  image-resize photo.png -w 800 -h 600 -o my-output.png"
    echo ""
    echo "Defaults:"
    echo "  width  = ${DEFAULT_WIDTH}"
    echo "  height = ${DEFAULT_HEIGHT}"
    echo ""
}

# ----------------------------------------
# Ensure at least 1 argument exists
# ----------------------------------------
if [ $# -lt 1 ]; then
    echo "❌ Error: Missing <imageSource>"
    print_usage
    exit 1
fi

# ----------------------------------------
# Check magick exists
# ----------------------------------------
if ! command -v magick.exe >/dev/null 2>&1; then
    echo "❌ Error: ImageMagick command 'magick' is not installed."
    echo "Please install ImageMagick and try again."
    exit 1
fi

# ----------------------------------------
# Required positional arg
# ----------------------------------------
IMAGE_SOURCE="$1"
shift

# ----------------------------------------
# Validate source image exists
# ----------------------------------------
if [ ! -f "$IMAGE_SOURCE" ]; then
    echo "❌ Error: File does not exist:"
    echo "  $IMAGE_SOURCE"
    exit 1
fi

# ----------------------------------------
# Optional args
# ----------------------------------------
WIDTH="$DEFAULT_WIDTH"
HEIGHT="$DEFAULT_HEIGHT"
CUSTOM_OUTPUT_NAME=""

while getopts "w:h:o:" opt; do
    case ${opt} in
        w)
            WIDTH="$OPTARG"
            ;;
        h)
            HEIGHT="$OPTARG"
            ;;
        o)
            CUSTOM_OUTPUT_NAME="$OPTARG"
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
done

# ----------------------------------------
# File path parsing
# ----------------------------------------
SOURCE_DIR="$(dirname "$IMAGE_SOURCE")"
SOURCE_FILE="$(basename "$IMAGE_SOURCE")"

SOURCE_NAME="${SOURCE_FILE%.*}"
SOURCE_EXT="${SOURCE_FILE##*.}"

SUFFIX="-resized-${WIDTH}-${HEIGHT}"

# ----------------------------------------
# Determine output filename
# Always enforce suffix
# ----------------------------------------
if [ -n "$CUSTOM_OUTPUT_NAME" ]; then

    CUSTOM_BASE="$(basename "$CUSTOM_OUTPUT_NAME")"

    # Remove extension if provided
    CUSTOM_NAME_ONLY="${CUSTOM_BASE%.*}"

    OUTPUT_FILE="${CUSTOM_NAME_ONLY}${SUFFIX}.${SOURCE_EXT}"
else
    OUTPUT_FILE="${SOURCE_NAME}${SUFFIX}.${SOURCE_EXT}"
fi

OUTPUT_PATH="${SOURCE_DIR}/${OUTPUT_FILE}"

# ----------------------------------------
# Resize image
# ----------------------------------------
echo "🔃 Resizing image..."
echo "  Source : $IMAGE_SOURCE"
echo "  Width  : $WIDTH"
echo "  Height : $HEIGHT"
echo "  Output : $OUTPUT_PATH"

magick.exe "$IMAGE_SOURCE" -resize "${WIDTH}x${HEIGHT}" "$OUTPUT_PATH"

echo ""
echo "✅ Done!"
echo "Saved resized image to:"
echo "  $OUTPUT_PATH"

echo ""
echo "📷   ImageResize finished 🎨"
echo "───────────────────────────────────────────────────────────────"