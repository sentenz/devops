#!/bin/bash
#
# Perform dependency setup for continuous testing pipeline.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/pkg.sh

# Constant variables

readonly -a APT_PACKAGES=(
  software-properties-common
  build-essential
  golang-go
)

# Internal functions

setup_testing() {
  local -i retval=0

  pkg_install_apt_list "${APT_PACKAGES[@]}"
  ((retval |= $?))

  pkg_cleanup_apt
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

setup_testing
exit "${?}"
