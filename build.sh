#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# veracrypt
curl -Lo /etc/yum.repos.d/_copr_robot-veracrypt-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/robot/veracrypt/repo/fedora-"${RELEASE}"/robot-veracrypt-fedora-"${RELEASE}".repo

# wezterm
curl -Lo /etc/yum.repos.d/_copr_wezfurlong-wezterm-nightly-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/wezfurlong/wezterm-nightly/repo/fedora-"${RELEASE}"/wezfurlong-wezterm-nightly-fedora-"${RELEASE}".repo

# Terminal tools
rpm-ostree install zoxide
rpm-ostree install stow
rpm-ostree install git
rpm-ostree install zsh
rpm-ostree install fastfetch
rpm-ostree install wezterm

# essentials for homebrew
rpm-ostree install gcc
rpm-ostree install g++
rpm-ostree install make
rpm-ostree install automake
rpm-ostree install autoconf
rpm-ostree install glibc-devel
rpm-ostree install libstdc++-devel
rpm-ostree install binutils
rpm-ostree install kernel-devel

# this would install a package from rpmfusion
# rpm-ostree install vlc

### Example for enabling a System Unit File

systemctl enable podman.socket

### modifications to config
# ZRAM conf
cp /usr/lib/systemd/zram-generator.conf /usr/lib/systemd/zram-generator.conf.bkp
echo -e "\n# Default algorithm changed from lzo-rle to zstd \ncompression-algorithm = zstd" | tee -a /usr/lib/systemd/zram-generator.conf
echo -e "# zram conf copied from PopOS\nvm.swappiness = 180\nvm.watermark_boost_factor = 0\nvm.watermark_scale_factor = 125\nvm.page-cluster = 0" | tee -a /etc/sysctl.d/99-vm-zram-parameters.conf

# WiFi configuration
echo -e "[connection]\nwifi.powersave=2\n" | tee -a /etc/NetworkManager/conf.d/wifi-powersave-off.conf
