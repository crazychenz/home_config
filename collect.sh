#!/bin/sh

mkdir -p downloads/x64-linux
mkdir -p bundle/x64-linux

rm -rf bundle/x64-linux/.*

export ARCH_OS=x64-linux 
export UID=$(id -u) 
export GID=$(id -g)
if [ -z "${OPEN_SHELL}" ]; then
  export OPEN_SHELL=yes
fi

docker compose run --rm collector
