#!/bin/bash

ROOT_UID=0
DEST_DIR=
THEME_NAME=$(grep "Name" dist/index.theme | sed 's/.*=\(.*\)Cursors$/\1/')

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

if [ -d "$DEST_DIR/$THEME_NAME-cursors" ]; then
  rm -r "$DEST_DIR/$THEME_NAME-cursors"
fi

cp -r dist "$DEST_DIR/$THEME_NAME-cursors"

echo "Finished..."
