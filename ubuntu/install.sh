#!bin/bash -e

function init() {
  mkdir -p ~/workspace
  timedatectl set-timezone Asia/Tokyo || :
  apt update && apt upgrade
}

function package_install() {
  apt install -y \
    linux-headers-$(uname -r) \
    linux-tools-$(uname -r) \
    linux-cloud-tools -$(uname -r)

  apt install -y \
    build-essential \
    curl \
    file \
    git \
    winget \
    fish \
    neovim \
    ghq \
    fzf \
    unzip \
    gcc \
    make \
    g++ \
}
