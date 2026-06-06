# ⚙️ Servers Setup Script

> **One-command environment setup for Android ROM building, kernel compilation, and Android development** — works on any Debian/Ubuntu-based system.

---

## ✨ Features

- 🔇 **Fully silent installs** — no apt noise, only clean status messages
- 🧠 **Smart distro detection** — reads `/etc/os-release` and adapts automatically
- 🔁 **Fallback logic** — tries alternative package names/versions before giving up (e.g. `lldb-18 → lldb-17 → ...`)
- 🛡️ **Non-breaking** — skipped packages are warned about, never crash the script
- 📊 **Real-time progress** — per-step progress bar that resets and tracks every package
- 🎨 **Colored output** — clear visual steps so you always know what's happening
- 📦 **PPA auto-setup** — adds `ubuntu-toolchain-r/test` on Ubuntu for newer cross-compilers

---

## 📦 What Gets Installed

| Category | Packages |
|---|---|
| **Core Build** | gcc, g++, make, cmake, ninja, bison, flex, ccache... |
| **Clang / LLVM** | clang, lld, llvm, lldb |
| **Cross Compilers** | gcc-aarch64-linux-gnu, gcc-arm-linux-gnueabihf/eabi |
| **Python** | python3, python-is-python3 |
| **Java** | openjdk-21-jdk (falls back to 17) |
| **Libraries** | libssl, zlib, brotli, lz4, zstd, pcre2, protobuf, ncurses... |
| **Kernel Tools** | pahole, dwarves, dtc, kmod, cpio, lzop |
| **Android Tools** | adb, fastboot, apktool, zipalign, erofs-utils |
| **Compression** | squashfs-tools, zip, bzip2, zstd, fakeroot |
| **VCS & Network** | git, git-lfs, gh (GitHub CLI), wget, curl |
| **Multimedia** | ffmpeg, webp, imagemagick |
| **Dev Utilities** | nano, jq, dos2unix, rsync, schedtool, fuse, npm, golang |

---

## 🖥️ Compatibility

| Distro | Status |
|---|---|
| Ubuntu 22.04 LTS | ✅ Tested |
| Ubuntu 24.04 LTS | ✅ Tested |
| Debian 12 (Bookworm) | ✅ Should work |
| Crave DevSpace | ✅ Tested |
| Termux proot-distro (Ubuntu) | ✅ Tested |
| Other apt-based distros | ⚠️ Best effort |

---

## 🚀 Usage

```bash
# Clone or download
git clone https://github.com/mrx7014/Servers-Setup-Script
cd Servers-Setup-Script

# Run
chmod +x setup.sh
./setup.sh
```

---

## 📋 Sample Output

```
  Servers Setup Script by MRX7014

── System Update

  ████████████████████████████████████████ 100%  done

── Build Tools

  ██████████████░░░░░░░░░░░░░░░░░░░░░░░░░░  35%  cmake

── Clang / LLVM

  ████████████████████████████████████████ 100%  done
[+] lldb → lldb-18

── Cross Compilers

  ████████████████████████████████████████ 100%  done

── Libraries

  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  20%  libelf-dev

...

✓ Done
```

---

## 🔧 How It Works

The script uses three helpers:

```bash
install_pkgs "Step Name" pkg1 pkg2 ...
# installs a list of packages with a real-time progress bar
# skipped packages are reported at the end of the step

install_any "desc" pkg-a pkg-b pkg-c
# tries each name in order, uses the first one that works
# used for packages like lldb that change name by version

run_update
# runs apt-get update + upgrade with a progress bar
```

Each step resets the progress bar from 0% and tracks every package individually. A single unavailable package **never blocks** the rest of the setup.

---

## 📄 License

MIT — do whatever you want with it.

---

<p align="center">By <strong>MRX7014</strong></p>
