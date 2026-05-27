#!/bin/bash
# Standalone build script for mc-rtc-superbuild on Ubuntu
# Intended to be run in a clean Ubuntu 22.04 or 24.04 environment.
# docker run --rm -e DEBIAN_FRONTEND=noninteractive -v $(pwd)/run_vanilla_test.sh:/test.sh ubuntu:24.04 bash -c "apt-get update && apt-get install -y sudo && bash /test.sh"

set -e

echo "--- 1. Installing basic system tools ---"
sudo apt-get update
sudo apt-get install git -y
# sudo apt-get install -y git cmake sudo curl python3 python3-pip

echo "--- 2. Cloning mc-rtc-superbuild ---"
if [ -d "mc-rtc-superbuild" ]; then
    rm -rf mc-rtc-superbuild
fi
git clone https://github.com/Kooolkimooov/mc-rtc-superbuild.git --branch tests

echo "--- 3. Bootstrapping system dependencies ---"
# This script installs apt packages, ROS, and other library dependencies
cd mc-rtc-superbuild
./utils/bootstrap-linux.sh
cd ..

git config --global user.name "Full Name"
git config --global user.email "your.email@provider.com"

echo "--- 4. Configuring the superbuild ---"
cmake -S mc-rtc-superbuild -B mc-rtc-superbuild/build -DSOURCE_DESTINATION=${HOME}/workspace/src -DBUILD_DESTINATION=${HOME}/workspace/build -DCMAKE_INSTALL_PREFIX=${HOME}/workspace/install

echo "--- 5. Cloning sub-projects ---"
cmake --build mc-rtc-superbuild/build --config RelWithDebInfo --target clone

echo "--- 6. Starting the build process ---"
# Build everything in the superbuild
cmake --build mc-rtc-superbuild/build --target install --config RelWithDebInfo

echo "--- BUILD SUCCESSFUL ---"
