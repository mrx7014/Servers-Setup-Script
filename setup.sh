#!/bin/bash
clear
echo "Servers Setup Script"
echo "By: MRX7014"
sleep 3
set -e
cd ~
export DEBIAN_FRONTEND=noninteractive
echo "[*] Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y
echo "[*] Installing build dependencies..."
sudo apt-get install -y \
  android-tools-adb android-tools-fastboot \
  apktool apt-utils attr automake autoconf \
  bc bison binutils build-essential bzip2 \
  ccache clang clang-11 cmake cpio curl \
  device-tree-compiler dialog dos2unix dwarves \
  erofs-utils expect \
  fakeroot flex ffmpeg fuse \
  g++ g++-10 g++-multilib gcc gcc-multilib \
  gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-linux-gnueabi \
  gawk gh git git-lfs gnupg golang gperf \
  imagemagick jq \
  kmod \
  lib32readline-dev lib32z1-dev \
  libbrotli-dev libc++-dev libc++abi-dev \
  libelf-dev libgtest-dev liblz4-dev liblz4-tool \
  libncurses-dev libncurses5-dev libncursesw5-dev \
  libpcre2-dev libprotobuf-dev libsdl1.2-dev \
  libssl-dev libstdc++6 libstdc++-12-dev libstdc++-14-dev \
  libunwind-dev libxml2 libxml2-utils \
  libzstd-dev lldb lld llvm locate lzop lz4 \
  make \
  nano ninja-build npm \
  openssl \
  pahole pcre2-utils perl pkg-config pngcrush \
  protobuf-compiler python3 python-is-python3 \
  rsync \
  schedtool sed squashfs-tools \
  tar unzip \
  webp wget \
  xsltproc xz-utils \
  zip zipalign zlib1g-dev zstd \
  openjdk-21-jdk
echo "[*] Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean
echo ""
echo "Done! Environment is ready."
