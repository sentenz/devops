#!/bin/bash
#
# Perform devops environment setup.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Internal functions

function setup() {
  local -i retval=0

  # Install ansible
  sudo apt update
  sudo apt install -y ansible
  ((retval |= $?))

  # Install taskfile
  sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

setup
exit "${?}"
