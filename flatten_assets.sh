#!/bin/bash
set -e

TARGET="build/web/assets"

# Make sure nested folder exists
if [ -d "$TARGET/assets" ]; then
echo "Flattening $TARGET/assets into $TARGET"

# Move all files and directories up one level
find "$TARGET/assets" -mindepth 1 -maxdepth 1 -exec mv {} "$TARGET/" \;

# Remove the now-empty nested folder
rm -rf "$TARGET/assets"

echo "Assets flattened successfully."
else
echo "No nested assets folder found."
fi

//run
//chmod +x flatten_assets.sh
