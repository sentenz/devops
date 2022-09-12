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
  npm
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

post_cleanup() {
  local -i result=0

  cleanup_apt
  ((result |= $?))

  cleanup_npm
  ((result |= $?))

  monitor "setup" "post-cleanup" "${result}"

  return "${result}"
}

setup_continuous_release() {
  local -i result=0

  setup_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  setup_npm_packages "${NPM_PACKAGES[@]}"
  ((result |= $?))

  post_cleanup
  ((result |= $?))

  return "${result}"
}

# Control flow logic

setup_continuous_release
exit "${?}"
