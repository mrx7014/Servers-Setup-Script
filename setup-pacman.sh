#!/bin/bash

echo "Setup Script For Arch Linux"

sudo pacman -Su
sudo pacman -Syu
sudo pacman -S base-devel git repo bc wget python
sudo pacman -S android-tools
sudo pacman -S arm-none-eabi-gcc
sudo pacman -S --no-confirm repo

echo "Done"

clear
