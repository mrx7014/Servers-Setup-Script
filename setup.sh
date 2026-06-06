#!/bin/bash
clear

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[*]${NC} $1"; }
step() { echo -e "\n${BLUE}──${NC} $1"; }

apt_q() { sudo apt-get install -y --no-install-recommends "$@" > /dev/null 2>&1; }

try() {
    apt_q "$1" && return 0
    warn "skip: $1"; return 1
}

grp() {
    local failed=()
    for pkg in "$@"; do apt_q "$pkg" || failed+=("$pkg"); done
    [ ${#failed[@]} -gt 0 ] && warn "skipped: ${failed[*]}"
}

any() {
    local desc="$1"; shift
    for pkg in "$@"; do
        apt_q "$pkg" && ok "$desc: $pkg" && return 0
    done
    warn "not found: $desc"
}

export DEBIAN_FRONTEND=noninteractive

echo -e "\n${GREEN}Servers Setup Script — by MRX7014${NC}\n"

step "System"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    info "$ID $VERSION_ID"
    [ "$ID" = "ubuntu" ] && sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test > /dev/null 2>&1
fi
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get upgrade -y > /dev/null 2>&1
ok "updated"

step "Build tools"
grp build-essential make ninja-build cmake automake autoconf \
    gcc g++ binutils bison flex bc gawk gperf ccache pkg-config

step "Clang / LLVM"
grp clang lld llvm
try clang-11
any "lldb" lldb lldb-18 lldb-17 lldb-16 lldb-15 lldb-14

step "Cross compilers"
grp gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-linux-gnueabi

step "Python / Java"
grp python3 python-is-python3
apt_q openjdk-21-jdk || apt_q openjdk-17-jdk || warn "no JDK"

step "Libraries"
grp libssl-dev zlib1g-dev libbrotli-dev liblz4-dev libzstd-dev \
    libpcre2-dev libprotobuf-dev protobuf-compiler libgtest-dev \
    libncurses-dev libstdc++-12-dev libstdc++-14-dev \
    libc++-dev libc++abi-dev libelf-dev \
    libsdl1.2-dev libxml2 libxml2-utils \
    lib32readline-dev lib32z1-dev

step "Kernel tools"
grp pahole dwarves device-tree-compiler kmod cpio xz-utils lz4 lzop

step "Android tools"
grp android-tools-adb android-tools-fastboot apktool zipalign erofs-utils

step "Misc"
grp squashfs-tools zip unzip bzip2 zstd fakeroot attr \
    git git-lfs gh wget curl \
    ffmpeg webp imagemagick \
    nano dos2unix jq dialog expect rsync schedtool \
    pngcrush xsltproc locate apt-utils fuse npm golang \
    pcre2-utils perl liblz4-tool gnupg gperf

step "Cleanup"
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get clean > /dev/null 2>&1

echo -e "\n${GREEN}✓ Done${NC}\n"
