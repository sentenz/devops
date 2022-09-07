#!/bin/bash
#
# Perform environment setup.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Include libraries

. ./../scripts/utils/log.sh
. ./../scripts/utils/util.sh

# Constant variables

readonly -a APT_REPOS=(
  "ppa:git-core/ppa"
)
readonly -a APT_PACKAGES=(
  build-essential
  git
  automake
  python3.8
  python-is-python3
  python3-pip
  gcc-9
  snapd
  cmake
  make
  apt-transport-https
  lsb-release
  ca-certificates
  dirmngr
)

# Internal functions

install_apt_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    install_apt "${package}"
    ((result |= $?))

    monitor "install" "${package}" "${result}"
  done

  return "${result}"
}

add_apt_repositories() {
  local -a repos=("$@")

  local -i result=0

  install_apt_packages "software-properties-common"
  ((result |= $?))

  for repo in "${repos[@]}"; do
    add_apt_ppa "${repo}"
    ((result |= $?))

    monitor "install" "update ${repo}" "${result}"
  done

  sudo apt update
  ((result |= $?))

  return "${result}"
}

post_cleanup() {
  local -i result=0

  sudo apt install -y -f
  ((result |= $?))

  sudo apt autoremove -y
  ((result |= $?))

  sudo apt clean
  ((result |= $?))

  sudo rm -rf /var/lib/apt/lists/*
  ((result |= $?))

  monitor "install" "post-cleanup" "${result}"

  return "${result}"
}

setup() {
  local -i result=0

  add_apt_repositories "${APT_REPOS[@]}"
  ((result |= $?))

  install_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  post_cleanup
  ((result |= $?))

  return "${result}"
}

# Control flow logic

setup
exit "${?}"
