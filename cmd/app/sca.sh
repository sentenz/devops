#!/bin/bash
#
# Perform software composition analysis (sca).

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Options

F_PATH="NULL"
while getopts 'p:' flag; do
  case "${flag}" in
    p) F_PATH="${OPTARG}" ;;
    *) ;;
  esac
done
readonly F_PATH

# Internal functions

security() {
  local f_path="${1:?path is missing}"

  (
    local -i result=0

    cd "$(fs_sript_dir)/../../internal/app" || return "${STATUS_ERROR}"

    chmod +x security.sh
    ./security.sh -p "${f_path}"
    ((result |= $?))

    return "${result}"
  )
}

run_sca() {
  local -i result=0

  security "${F_PATH}"
  ((result |= $?))

  return "${result}"
}

# Control flow logic

run_sca
exit "${?}"
