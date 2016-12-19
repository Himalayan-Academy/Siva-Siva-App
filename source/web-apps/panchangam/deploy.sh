#!/bin/bash

SRC_PATH="."
DEST_PATH="../../../modules/panchangam/web"


echo "Bundling app..."
./bundle.sh

echo "Deploying app to Panchangam modules folder..."

if [ -d "$DEST_PATH" ]; then rm -Rf $DEST_PATH; fi

mkdir -p "$DEST_PATH"
mkdir -p "$DEST_PATH/jspm_packages"


cp -R "$SRC_PATH/css" "$DEST_PATH"
cp -R "$SRC_PATH/fonts" "$DEST_PATH"
cp -R "$SRC_PATH/fonts" "$DEST_PATH"
cp -R "$SRC_PATH/images" "$DEST_PATH"

cp -R "$SRC_PATH/config.js" "$DEST_PATH"
cp -R "$SRC_PATH/hawaii.ics" "$DEST_PATH"

cp -R "$SRC_PATH/jspm_packages/system.js" "$DEST_PATH/jspm_packages"
cp -R "$SRC_PATH/index.html" "$DEST_PATH"
cp -R "$SRC_PATH/build.js" "$DEST_PATH"

echo "Done!"