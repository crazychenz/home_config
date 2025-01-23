#!/bin/sh

mkdir -p downloads/x64-linux
mkdir -p bundle/x64-linux

ARCH_OS=x64-linux UID=$(id -u) GID=$(id -g) docker compose up
