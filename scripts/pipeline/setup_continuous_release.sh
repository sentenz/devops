#!/bin/bash
#
# Perform dependency setup for continuous release pipeline.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/util.sh

# Constant variables

readonly -a APT_PACKAGES=(
  nodejs
  npm
)
readonly -A NPM_PACKAGES=(
  [semantic-release]=17.4.7
  [semantic-commitlint]=latest
  [semantic-release-commitlint]=latest
  [@semantic-release/git]=latest
  [@semantic-release/changelog]=latest
  [@semantic-release/error]=latest
  [@semantic-release/exec]=latest
  [@semantic-release/commit-analyzer]=latest
  [@semantic-release/release-notes-generator]=latest
  [@semantic-release/github]=latest
  [semantic-release-ado]=latest
  # [@semantic-release/npm]=latest
)

# Internal functions

setup_continuous_release() {
  local -i result=0

  util_setup_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  # HACK(AK) I don't know how to pass key value pairs to function
  # util_setup_npm_packages "${NPM_PACKAGES[@]}"
  # ((result |= $?))
  for package in "${!NPM_PACKAGES[@]}"; do

    util_install_npm "${package}" "${NPM_PACKAGES[$package]}"
    ((result |= $?))

    log_message "setup" "${package}" "${result}"
  done

  util_cleanup_apt
  ((result |= $?))

  util_cleanup_npm
  ((result |= $?))

  return "${result}"
}

# Control flow logic

setup_continuous_release
exit "${?}"
