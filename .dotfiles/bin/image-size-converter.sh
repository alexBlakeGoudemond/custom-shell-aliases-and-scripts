#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------------
# image-size-converter: Convert image dimensions quickly using tool `magick` (ImageMagick)
# Usage: image-resize <imageSource> [-w width] [-h height] [-o outputName]
#
# For fun, we named this little tool as `image-resize`
# --------------------------------------------------------------------------------------------------------

set -e

ALIAS_VERSION="1.0.0"

echo ""
echo "📷   ImageResize $ALIAS_VERSION — Convert Image Dimensions with ImageMagick 🎨"
echo "───────────────────────────────────────────────────────────────"

DEFAULT_WIDTH=1280
DEFAULT_HEIGHT=800

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
}

ensure_image_source() {
    if [ -z "$IMAGE_SOURCE_ARG" ]; then
        echo "❌ Error: Missing <imageSource>"
        print_usage
        exit 1
    fi
}

ensure_image_magick_installed() {
    if ! command -v magick.exe >/dev/null 2>&1; then
        echo "❌ Error: ImageMagick command 'magick' is not installed."
        exit 1
    fi
}

validate_source_image_exists() {
    if [[ ! -f "$IMAGE_SOURCE" ]]; then
        echo "❌ Error: File does not exist:"
        echo "  $IMAGE_SOURCE"
        exit 1
    fi

    echo "✅ Found source image: $IMAGE_SOURCE"
}

parse_args() {
    WIDTH="$DEFAULT_WIDTH"
    HEIGHT="$DEFAULT_HEIGHT"
    CUSTOM_OUTPUT_NAME=""

    # Walk through all args and consume known flags. The first non-flag
    # argument is treated as the image source (if not already provided).
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -w|--width)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    WIDTH="$2"
                    shift 2
                else
                    echo "❌ Error: -w|--width requires a value"; exit 1
                fi
                ;;
            -h|--height)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    HEIGHT="$2"
                    shift 2
                else
                    echo "❌ Error: -h|--height requires a value"; exit 1
                fi
                ;;
            -o|--output)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    CUSTOM_OUTPUT_NAME="$2"
                    shift 2
                else
                    echo "❌ Error: -o|--output requires a value"; exit 1
                fi
                ;;
            --)
                shift; break
                ;;
            -*)
                echo "❌ Unknown option: $1"; print_usage; exit 1
                ;;
            *)
                # first non-option argument (if supplied here) is the image source
                if [ -z "$IMAGE_SOURCE_ARG" ]; then
                    IMAGE_SOURCE_ARG="$1"
                    shift
                else
                    # allow extra trailing args but warn
                    echo "⚠️  Ignoring extra argument: $1"
                    shift
                fi
                ;;
        esac
    done
}

determine_output_filename() {
    SUFFIX="-resized-${WIDTH}-${HEIGHT}"

    if [ -n "$CUSTOM_OUTPUT_NAME" ]; then
        CUSTOM_BASE="$(basename "$CUSTOM_OUTPUT_NAME")"
        CUSTOM_NAME_ONLY="${CUSTOM_BASE%.*}"
        OUTPUT_FILE="${CUSTOM_NAME_ONLY}${SUFFIX}.${SOURCE_EXT}"
    else
        OUTPUT_FILE="${SOURCE_NAME}${SUFFIX}.${SOURCE_EXT}"
    fi

    OUTPUT_PATH="${SOURCE_DIR}/${OUTPUT_FILE}"
}

resize_with_image_magick() {
    magick.exe "$IMAGE_SOURCE" -resize "${WIDTH}x${HEIGHT}!" "$OUTPUT_PATH"
}

# -------------------------------
# ENTRY POINT
# -------------------------------

IMAGE_SOURCE_ARG="$1"
shift

ensure_image_source
ensure_image_magick_installed

IMAGE_SOURCE="$(realpath "${GIT_PREFIX}${IMAGE_SOURCE_ARG}")"

validate_source_image_exists

parse_args "$@"

SOURCE_DIR="$(dirname "$IMAGE_SOURCE")"
SOURCE_FILE="$(basename "$IMAGE_SOURCE")"

SOURCE_NAME="${SOURCE_FILE%.*}"
SOURCE_EXT="${SOURCE_FILE##*.}"

determine_output_filename

echo "🔃 Resizing image to these exact dimensions (not aspect ratio)..."
echo "  Source : $IMAGE_SOURCE"
echo "  Width  : $WIDTH"
echo "  Height : $HEIGHT"
echo "  Output : $OUTPUT_PATH"

resize_with_image_magick

echo ""
echo "✅ Done!"
echo "Saved resized image to:"
echo "  $OUTPUT_PATH"

echo ""
echo "📷   ImageResize finished 🎨"
echo "───────────────────────────────────────────────────────────────"