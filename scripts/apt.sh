#!/bin/sh
set -e
cd "$(dirname "$0")/.."
sudo apt-get update
sudo apt-get install --no-install-recommends $(sed 's/#.*//' packages/apt.txt)
