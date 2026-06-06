#!/bin/bash
clear

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "\n${GREEN}[+]${NC} $1"; }
warn() { echo -e "\n${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[*]${NC} $1"; }
step() { echo -e "\n${BLUE}${BOLD}── $1${NC}"; }

export DEBIAN_FRONTEND=noninteractive

# ── Progress bar ────────────────────────────────────────
BAR_WIDTH=40
_progress() {
    local current=$1 total=$2 label=$3
    local pct=$(( current * 100 / total ))
    local filled=$(( current * BAR_WIDTH / total ))
    local empty=$(( BAR_WIDTH - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf "\r  ${GREEN}${bar}${NC} ${BOLD}%3d%%${NC}  ${CYAN}%s${NC}%-30s" "$pct" "$label" " "
}

# ── Install with progress ────────────────────────────────
# Usage: install_pkgs "Step Name" pkg1 pkg2 ...
install_pkgs() {
    local title="$1"; shift
    local pkgs=("$@")
    local total=${#pkgs[@]}
    local failed=()

    step "$title"
    echo ""

    for ((i=0; i<total; i++)); do
        local pkg="${pkgs[$i]}"
        _progress "$i" "$total" "$pkg"
        sudo apt-get install -y --no-install-recommends "$pkg" > /dev/null 2>&1 \
            || failed+=("$pkg")
    done

    _progress "$total" "$total" "done"
    echo ""

    [ ${#failed[@]} -gt 0 ] && warn "skipped: ${failed[*]}"
}

# ── Install with fallback (tries names until one works) ──
install_any() {
    local desc="$1"; shift
    for pkg in "$@"; do
        sudo apt-get install -y --no-install-recommends "$pkg" > /dev/null 2>&1 \
            && { ok "$desc → $pkg"; return 0; }
    done
    warn "not found: $desc"
}

# ── Simple silent update with progress simulation ────────
run_update() {
    step "System Update"
    echo ""
    local tasks=("apt-get update" "apt-get upgrade")
    local total=${#tasks[@]}

    _progress 0 $total "updating package lists..."
    sudo apt-get update -y > /dev/null 2>&1

    _progress 1 $total "upgrading packages..."
    sudo apt-get upgrade -y > /dev/null 2>&1

    _progress 2 $total "done"
    echo ""
    ok "system up to date"
}

# ════════════════════════════════════════════════════════
echo -e "\n${GREEN}${BOLD}  Servers Setup Script${NC} ${CYAN}by MRX7014${NC}\n"

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    info "Detected: $ID $VERSION_ID"
    if [ "$ID" = "ubuntu" ]; then
        info "Adding toolchain PPA..."
        sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test > /dev/null 2>&1
    fi
fi

run_update

install_pkgs "Build Tools" \
    build-essential make ninja-build cmake automake autoconf \
    gcc g++ binutils bison flex bc gawk gperf ccache pkg-config

install_pkgs "Clang / LLVM" \
    clang lld llvm clang-11

install_any "lldb" lldb lldb-18 lldb-17 lldb-16 lldb-15 lldb-14

install_pkgs "Cross Compilers" \
    gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-linux-gnueabi

install_pkgs "Python / Java" \
    python3 python-is-python3

step "Java (JDK)"
echo ""
_progress 0 1 "openjdk..."
sudo apt-get install -y --no-install-recommends openjdk-21-jdk > /dev/null 2>&1 \
    || sudo apt-get install -y --no-install-recommends openjdk-17-jdk > /dev/null 2>&1 \
    || warn "no JDK available"
_progress 1 1 "done"
echo ""

install_pkgs "Libraries" \
    libssl-dev zlib1g-dev libbrotli-dev liblz4-dev libzstd-dev \
    libpcre2-dev libprotobuf-dev protobuf-compiler libgtest-dev \
    libncurses-dev libstdc++-12-dev libstdc++-14-dev \
    libc++-dev libc++abi-dev libelf-dev \
    libsdl1.2-dev libxml2 libxml2-utils \
    lib32readline-dev lib32z1-dev

install_pkgs "Kernel Tools" \
    pahole dwarves device-tree-compiler kmod cpio xz-utils lz4 lzop

install_pkgs "Android Tools" \
    android-tools-adb android-tools-fastboot apktool zipalign erofs-utils

install_pkgs "Compression & Filesystem" \
    squashfs-tools zip unzip bzip2 zstd fakeroot attr

install_pkgs "Version Control & Network" \
    git git-lfs gh wget curl

install_pkgs "Multimedia" \
    ffmpeg webp imagemagick

install_pkgs "Dev Utilities" \
    nano dos2unix jq dialog expect rsync schedtool \
    pngcrush xsltproc locate apt-utils fuse npm golang

install_pkgs "Optional" \
    pcre2-utils perl liblz4-tool gnupg gperf

step "Cleanup"
echo ""
_progress 0 2 "autoremove..."
sudo apt-get autoremove -y > /dev/null 2>&1
_progress 1 2 "clean..."
sudo apt-get clean > /dev/null 2>&1
_progress 2 2 "done"
echo ""

echo -e "\n${GREEN}${BOLD}✓ Done${NC}\n"
