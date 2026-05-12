#!/bin/bash

set -e

ITEM_PATH="$1"
BG_FILE="$2"

if [ -z "$ITEM_PATH" ] || [ ! -e "$ITEM_PATH" ]; then
    echo "Usage: "
    echo "./make_installer_dmg.sh YourFile.dictionary background.png"
    exit 1
fi

if ! command -v create-dmg &>/dev/null; then
    brew install create-dmg
fi

ITEM_NAME="$(basename "$ITEM_PATH")"
ITEM_BASE="${ITEM_NAME%.*}"
ITEM_EXT="${ITEM_NAME##*.}"

WORK_DIR="$(mktemp -d)"
STAGING_DIR="$WORK_DIR/staging"

mkdir -p "$STAGING_DIR"

OUTPUT_DMG="${ITEM_BASE}.dmg"

cp -R "$ITEM_PATH" "$STAGING_DIR/"

TARGET_NAME="Drag to Here"

case "$ITEM_EXT" in

    dictionary)
        TARGET_PATH="$HOME/Library/Dictionaries"
        ;;

    qlgenerator)
        TARGET_PATH="$HOME/Library/QuickLook"
        ;;

    plugin)
        TARGET_PATH="$HOME/Library/Internet Plug-Ins"
        ;;

    bundle)
        TARGET_PATH="$HOME/Library/Application Support"
        ;;

    app)
        TARGET_PATH="/Applications"
        ;;

    *)
        TARGET_PATH="$HOME/Library/Application Support"
        ;;

esac

ln -s "$TARGET_PATH" "$STAGING_DIR/$TARGET_NAME"

if [ -n "$BG_FILE" ] && [ -f "$BG_FILE" ]; then
    BACKGROUND_OPTION=(--background "$BG_FILE")
else
    BACKGROUND_OPTION=()
fi

create-dmg \
    --volname "$ITEM_BASE" \
    --window-size 900 600 \
    --window-pos 200 120 \
    --icon-size 120 \
    --text-size 16 \
    --icon "$ITEM_NAME" 230 285 \
    --icon "$TARGET_NAME" 665 285 \
    --hide-extension "$ITEM_NAME" \
    --hide-extension "$TARGET_NAME" \
    --no-internet-enable \
    "${BACKGROUND_OPTION[@]}" \
    "$OUTPUT_DMG" \
    "$STAGING_DIR"