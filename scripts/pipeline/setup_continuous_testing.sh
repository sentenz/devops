#!/bin/bash
#
# Perform dependency setup for continuous testing pipeline.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Include libraries

. ./../../scripts/utils/log.sh
. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh
. ./../../scripts/utils/util.sh

# Constant variables

readonly -a APT_PACKAGES=(
  software-properties-common
  build-essential
  golang-go
)

# Internal functions

post_cleanup() {
  local -i result=0

  cleanup_apt
  ((result |= $?))

  monitor "setup" "post-cleanup" "${result}"

  return "${result}"
}

setup_continuous_testing() {
  local -i result=0

  setup_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  post_cleanup
  ((result |= $?))

  return "${result}"
}

# Control flow logic

setup_continuous_testing
exit "${?}"
