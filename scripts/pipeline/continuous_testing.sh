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

readonly GO_DEPENDENY="https://dl.google.com/go/go1.18.linux-amd64.tar.gz"

# Internal functions

install_go_dependency() {
  local dependency="${1:?dependency is missing}"

  local -i result=0
  if is_file "$(get_root_dir)/go.mod"; then
    name="$(basename "${dependency}")"

    if ! command -v go &>/dev/null; then
      wget "${dependency}"
      ((result |= $?))
      sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "${name}" && sudo rm -f "${name}"
      ((result |= $?))
    fi
    export PATH=/usr/local/go/bin:"${PATH}"

    monitor "setup" "${name}" "${result}"
  fi

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

  monitor "setup" "post-cleanup" "${result}"

  return "${result}"
}

continuous_testing() {
  local -i result=0

  install_go_dependency "${GO_DEPENDENY}"
  ((result |= $?))

  post_cleanup
  ((result |= $?))

  return "${result}"
}

# Control flow logic

continuous_testing
exit "${?}"
