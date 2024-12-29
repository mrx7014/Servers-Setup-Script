#! /bin/bash
clear
echo "Servers Setup Script"
echo "By: MRX7014"
sleep 3
cd
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install cmake clang clang-11 pkg-config libbrotli-dev liblz4-dev libpcre2-dev libzstd-dev protobuf-compiler libprotobuf-dev ccache build-essential ninja-build bc bison flex libssl-dev gcc g++ libstdc++-12-dev lld locate libstdc++-14-dev libgtest-dev
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick  lib32readline-dev lib32z1-dev liblz4-tool  libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt-get update -y && sudo apt-get install dialog bash sed wget git curl zip tar jq expect make cmake automake autoconf llvm lld lldb clang gcc binutils bison perl gperf gawk flex bc python3 python2 zstd openssl unzip cpio bc bison build-essential ccache liblz4-tool libsdl1.2-dev libstdc++6 libxml2 libxml2-utils lzop pngcrush schedtool squashfs-tools xsltproc zlib1g-dev libncurses5-dev bzip2 git gcc g++ libssl-dev gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-linux-gnueabi dos2unix neofetch -y
sudo apt install git aria2 -y ; git clone https://gitlab.com/OrangeFox/misc/scripts ; cd scripts ; sudo bash setup/android_build_env.sh ; sudo bash setup/install_android_sdk.sh
curl https://raw.githubusercontent.com/mrx7014/android_ndk_sdk_installer/main/android_ndk_sdk_installer.sh >> android_ndk_sdk_installer.sh && chmod +x android_ndk_sdk_installer.sh && ./android_ndk_sdk_installer.sh
echo "Done"
