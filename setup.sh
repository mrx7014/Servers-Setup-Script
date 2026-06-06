#!/bin/bash
clear

# ============================================
#   Servers Setup Script
#   By: MRX7014
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; }
info()   { echo -e "${CYAN}[*]${NC} $1"; }

# ── تثبيت package مع تجاهل الفشل ──────────────────
try_install() {
    local pkg="$1"
    if sudo apt-get install -y --no-install-recommends "$pkg" \
        2>/dev/null 1>/dev/null; then
        return 0
    else
        warn "Skipped (unavailable): $pkg"
        return 1
    fi
}

# ── تثبيت قائمة packages مع تجاهل المتعارضة ────────
install_group() {
    local desc="$1"; shift
    local failed=()
    info "Installing: $desc"
    for pkg in "$@"; do
        try_install "$pkg" || failed+=("$pkg")
    done
    if [ ${#failed[@]} -gt 0 ]; then
        warn "Skipped packages: ${failed[*]}"
    fi
}

# ── اكتشاف الـ distro والـ version ──────────────────
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

# ── إضافة PPAs لو Ubuntu ────────────────────────────
setup_repos() {
    if [ "${DISTRO_ID}" = "ubuntu" ]; then
        log "Adding Ubuntu toolchain PPA..."
        sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test 2>/dev/null || \
            warn "Could not add toolchain PPA (non-fatal)"
    fi
}

# ════════════════════════════════════════════
echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║   Servers Setup Script           ║"
echo "  ║   By: MRX7014                    ║"
echo "  ╚══════════════════════════════════╝"
echo ""
sleep 2

export DEBIAN_FRONTEND=noninteractive

detect_distro
setup_repos

log "Updating package lists..."
sudo apt-get update -y

log "Upgrading installed packages..."
sudo apt-get upgrade -y

# ── Core Build Tools ────────────────────────────────
install_group "Core build tools" \
    build-essential make ninja-build cmake automake autoconf \
    gcc g++ binutils bison flex bc gawk gperf \
    ccache pkg-config

# ── Clang / LLVM ────────────────────────────────────
install_group "Clang / LLVM" \
    clang lld llvm lldb

# بيجرب clang-11 لو الـ default مش كافي
try_install clang-11

# ── Cross Compilers ─────────────────────────────────
install_group "Cross compilers (ARM/AArch64)" \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-arm-linux-gnueabi

# ── Python ──────────────────────────────────────────
install_group "Python" \
    python3 python-is-python3

# ── Java ────────────────────────────────────────────
# بيجرب 21 الأول، لو مش موجود يجرب 17
if ! try_install openjdk-21-jdk; then
    warn "openjdk-21 not available, trying openjdk-17..."
    try_install openjdk-17-jdk || warn "No JDK installed"
fi

# ── Libraries ───────────────────────────────────────
install_group "Libraries" \
    libssl-dev zlib1g-dev libelf-dev \
    libbrotli-dev liblz4-dev libzstd-dev \
    libpcre2-dev libprotobuf-dev protobuf-compiler \
    libgtest-dev libncurses-dev \
    libstdc++-12-dev libstdc++-14-dev \
    libc++-dev libc++abi-dev \
    libsdl1.2-dev libxml2 libxml2-utils \
    lib32readline-dev lib32z1-dev

# ── Kernel Build Tools ──────────────────────────────
install_group "Kernel build tools" \
    libelf-dev pahole dwarves \
    device-tree-compiler kmod \
    cpio xz-utils lz4 lzop

# ── Android Tools ───────────────────────────────────
install_group "Android tools" \
    android-tools-adb android-tools-fastboot \
    apktool zipalign erofs-utils

# ── Compression / Filesystem ────────────────────────
install_group "Compression / filesystem tools" \
    squashfs-tools fakeroot attr \
    zip unzip bzip2 zstd

# ── Network / Download ──────────────────────────────
install_group "Network tools" \
    wget curl git git-lfs gh

# ── Multimedia ──────────────────────────────────────
install_group "Multimedia" \
    ffmpeg webp imagemagick

# ── Dev Utilities ───────────────────────────────────
install_group "Dev utilities" \
    nano dos2unix jq dialog expect \
    rsync schedtool pngcrush xsltproc \
    locate apt-utils fuse \
    npm golang

# ── Optional heavy packages ─────────────────────────
install_group "Optional packages" \
    pcre2-utils perl \
    liblz4-tool \
    gnupg gperf

# ── Cleanup ─────────────────────────────────────────
log "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Setup completed successfully!    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
