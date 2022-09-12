#!/bin/bash
#
# Perform dependency setup for continuous release pipeline.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Include libraries

. ./../../scripts/utils/log.sh
. ./../../scripts/utils/util.sh

# Constant variables

readonly -a APT_PACKAGES=(
  nodejs
)
readonly -a NPM_PACKAGES=(
  semantic-release
  semantic-commitlint
  semantic-release-commitlint
  @semantic-release/git
  @semantic-release/changelog
  @semantic-release/error
  @semantic-release/exec
  @semantic-release/commit-analyzer
  @semantic-release/release-notes-generator
  @semantic-release/github
  semantic-release-ado
  # @semantic-release/npm
)

# Internal functions

install_apt_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    install_apt "${package}"
    ((result |= $?))

    monitor "setup" "${package}" "${result}"
  done

  return "${result}"
}

install_npm_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    install_npm "${package}"
    ((result |= $?))

    monitor "setup" "${package}" "${result}"
  done

  return "${result}"
}

continuous_release() {
  local -i result=0

  install_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  install_npm_packages "${NPM_PACKAGES[@]}"
  ((result |= $?))

  return "${result}"
}

# Control flow logic

continuous_release
exit "${?}"
