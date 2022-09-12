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
readonly -a APT_PACKAGES=(
  software-properties-common
  build-essential
  git
  automake
  python3
  python-is-python3
  python3-pip
  gcc
  cmake
  make
  dirmngr
  lsb-release
)

# Internal functions

install_apt_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    update_apt

    install_apt "${package}"
    ((result |= $?))

    monitor "install" "${package}" "${result}"
  done

  return "${result}"
}

post_cleanup() {
  local -i result=0

  cleanup_apt
  ((result |= $?))

  monitor "install" "post-cleanup" "${result}"

  return "${result}"
}

setup() {
  local -i result=0

  install_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  post_cleanup
  ((result |= $?))

  return "${result}"
}

# Control flow logic

setup
exit "${?}"
