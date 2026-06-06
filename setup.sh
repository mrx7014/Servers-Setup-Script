#!/bin/bash
clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; }
info()   { echo -e "${CYAN}[*]${NC} $1"; }
step()   { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

try_install() {
    local pkg="$1"
    sudo apt-get install -y --no-install-recommends "$pkg" \
        > /dev/null 2>&1 && return 0
    warn "Skipped (unavailable): $pkg"
    return 1
}

install_group() {
    local desc="$1"; shift
    local failed=()
    info "$desc"
    for pkg in "$@"; do
        try_install "$pkg" || failed+=("$pkg")
    done
    [ ${#failed[@]} -gt 0 ] && warn "Skipped: ${failed[*]}"
}

try_install_any() {
    local desc="$1"; shift
    for pkg in "$@"; do
        if sudo apt-get install -y --no-install-recommends "$pkg" \
            > /dev/null 2>&1; then
            log "Installed ($desc): $pkg"
            return 0
        fi
    done
    warn "Could not install $desc (tried: $*)"
    return 1
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID}"
        DISTRO_VERSION="${VERSION_ID}"
        DISTRO_CODENAME="${VERSION_CODENAME:-}"
    else
        DISTRO_ID="unknown"
        DISTRO_VERSION="0"
        DISTRO_CODENAME=""
    fi
    info "Detected: ${DISTRO_ID} ${DISTRO_VERSION} ${DISTRO_CODENAME:+(${DISTRO_CODENAME})}"
}

setup_repos() {
    if [ "${DISTRO_ID}" = "ubuntu" ]; then
        info "Adding toolchain PPA for newer gcc/cross-compiler versions..."
        sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test \
            > /dev/null 2>&1 || warn "Could not add toolchain PPA (non-fatal)"
        log "PPA added"
    fi
}

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║   Servers Setup Script           ║"
echo "  ║   By: MRX7014                    ║"
echo "  ╚══════════════════════════════════╝"
echo ""
sleep 2

export DEBIAN_FRONTEND=noninteractive

step "Detecting System"
detect_distro

step "Configuring Repositories"
setup_repos

step "Updating System"
info "Refreshing package lists from all sources..."
sudo apt-get update -y > /dev/null 2>&1
log "Package lists updated"

info "Upgrading installed packages to latest versions..."
sudo apt-get upgrade -y > /dev/null 2>&1
log "System upgraded"

step "Core Build Tools"
install_group "gcc, g++, make, cmake, ninja — compilers and build systems used to compile C/C++ projects and kernels" \
    build-essential make ninja-build cmake automake autoconf \
    gcc g++ binutils bison flex bc gawk gperf \
    ccache pkg-config

step "Clang / LLVM"
info "clang/lld/llvm — LLVM-based compiler toolchain, faster builds and required by many Android/kernel projects..."
install_group "Installing LLVM toolchain" \
    clang lld llvm
try_install clang-11
try_install_any "lldb (debugger)" \
    lldb lldb-18 lldb-17 lldb-16 lldb-15 lldb-14

step "Cross Compilers"
install_group "ARM 32-bit and AArch64 cross-compilers — needed to build kernels and binaries targeting Android devices from an x86 machine" \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-arm-linux-gnueabi

step "Python"
install_group "Python3 and python→python3 symlink — required by Android build system (soong, repo, scripts)" \
    python3 python-is-python3

step "Java (JDK)"
info "OpenJDK — required to compile Android apps and run build tools like aapt2, apksigner, d8..."
if ! try_install openjdk-21-jdk; then
    warn "openjdk-21 not available, trying openjdk-17..."
    try_install openjdk-17-jdk || warn "No JDK installed"
fi

step "Libraries"
install_group "SSL, zlib, brotli, lz4, zstd — compression and crypto libs used by Android tools and kernel build" \
    libssl-dev zlib1g-dev libbrotli-dev liblz4-dev libzstd-dev

install_group "PCRE2, protobuf — pattern matching and serialization libs used by Android build tools and adb" \
    libpcre2-dev libprotobuf-dev protobuf-compiler

install_group "GTest — Google's C++ unit testing framework, required by some AOSP components" \
    libgtest-dev

install_group "ncurses — terminal UI library, needed for kernel menuconfig and some build scripts" \
    libncurses-dev

install_group "libstdc++, libc++ — C++ standard library dev headers for both GCC and Clang builds" \
    libstdc++-12-dev libstdc++-14-dev \
    libc++-dev libc++abi-dev

install_group "libelf — ELF binary parsing, required for kernel builds (BTF, pahole, dwarves)" \
    libelf-dev

install_group "libsdl, libxml2 — SDL for emulator/graphics support, libxml2 for parsing build manifests" \
    libsdl1.2-dev libxml2 libxml2-utils

install_group "32-bit libs — multilib support for building 32-bit targets on 64-bit host" \
    lib32readline-dev lib32z1-dev

step "Kernel Build Tools"
install_group "pahole, dwarves — DWARF debug info tools required for BTF generation in modern kernel builds" \
    pahole dwarves

install_group "dtc (device-tree-compiler) — compiles .dts files into .dtb blobs loaded by Android bootloader" \
    device-tree-compiler

install_group "kmod, cpio, xz, lz4, lzop — kernel module tools and compression formats used in initramfs and boot images" \
    kmod cpio xz-utils lz4 lzop

step "Android Tools"
install_group "adb, fastboot — Android Debug Bridge and bootloader flashing tools" \
    android-tools-adb android-tools-fastboot

install_group "apktool — APK decompile/recompile tool for modding and analysis" \
    apktool

install_group "zipalign — aligns APK zip entries for optimal Android runtime performance" \
    zipalign

install_group "erofs-utils — tools for EROFS read-only filesystem used in modern Android system images" \
    erofs-utils

step "Compression & Filesystem Tools"
install_group "squashfs, zip, unzip, bzip2, zstd — archive formats used throughout Android build and ROM packaging" \
    squashfs-tools zip unzip bzip2 zstd

install_group "fakeroot, attr — simulate root for packaging; extended file attributes for Android filesystem images" \
    fakeroot attr

step "Version Control & Network"
install_group "git, git-lfs — version control; LFS for large binary files in AOSP and ROM repos" \
    git git-lfs

install_group "gh — GitHub CLI for managing repos, PRs, and releases from terminal" \
    gh

install_group "wget, curl — downloading files and interacting with APIs from scripts" \
    wget curl

step "Multimedia"
install_group "ffmpeg — video/audio processing, used by some build scripts and tools" \
    ffmpeg

install_group "webp, imagemagick — image conversion tools for processing Android assets and splash screens" \
    webp imagemagick

step "Dev Utilities"
install_group "nano, dos2unix — text editor and line-ending converter (fixes Windows CRLF in scripts)" \
    nano dos2unix

install_group "jq — parse and query JSON from shell scripts (used in build automation)" \
    jq

install_group "dialog, expect — interactive terminal prompts and automation of interactive programs" \
    dialog expect

install_group "rsync — fast file sync, used for copying build outputs and ROM files" \
    rsync

install_group "schedtool — set CPU scheduling policy to speed up long builds" \
    schedtool

install_group "pngcrush, xsltproc — PNG optimizer and XSLT processor used in AOSP resource compilation" \
    pngcrush xsltproc

install_group "locate, apt-utils, fuse — file search, apt helpers, and FUSE filesystem support" \
    locate apt-utils fuse

install_group "npm — Node.js package manager, needed by some build tools and web-based dev utilities" \
    npm

install_group "golang — Go language runtime, required by some Android/Termux tools (e.g. opencode, bazel plugins)" \
    golang

step "Optional Packages"
install_group "perl, gnupg, gperf, pcre2-utils, liblz4-tool — misc scripting, signing, hashing, and pattern tools" \
    pcre2-utils perl liblz4-tool gnupg gperf

step "Cleanup"
info "Removing unused packages and clearing apt cache..."
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get clean > /dev/null 2>&1
log "Cleanup done"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Setup completed successfully!    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
