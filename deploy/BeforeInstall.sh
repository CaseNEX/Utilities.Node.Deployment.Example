#!/bin/bash

# creates a temp directory to build the application

BUILD_ROOT='/home/www/node/build/'
BUILD_DIR='/home/www/node/build/HelloWorld/'

if [ ! -d "$BUILD_ROOT" ]; then
  mkdir "$BUILD_ROOT"
fi

rm -rf "$BUILD_DIR"

if [ ! -d "$BUILD_DIR" ]; then
  mkdir "$BUILD_DIR"
fi


