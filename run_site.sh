#!/bin/bash

EXISTING_INSTANCE="$(pidof target/release/master-of-zen-blog)"

if [ ! -z $EXISTING_INSTANCE ]; then
    kill $EXISTING_INSTANCE
fi

BIN_NAME="master-of-zen-blog"

if [ -f "master-of-zen-blog" ]; then
    ./$BIN_NAME
    exit $?
fi

if [ -f "Cargo.toml" ]; then
   cargo run --release
   exit $?
fi

echo "Could not find master-of-zen-blog executable or Cargo.toml"
