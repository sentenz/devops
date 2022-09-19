#!/bin/bash
#
# Perform dynamic application security testing (DAST).

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Options

F_BINARY="NULL"
while getopts 'b:' flag; do
  case "${flag}" in
    b) F_BINARY="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly F_BINARY

# Constant variables

pre_cleanup() {
  # Cleanup previous logs
  if is_dir_empty "$(get_root_dir)/logs"; then
    return 0
  fi

  local regex_patterns="^.*\.(log)$"
  find "$(get_root_dir)/logs" -type f -regextype posix-egrep -regex "${regex_patterns}" -delete
}

sanitizer() {
  local b_flag="${1:?binary flag is missing}"

  (
    local -i result=0

    cd "$(get_sript_dir)/../../internal/app" || return 1

    chmod +x sanitizer.sh
    ./sanitizer.sh -b "${b_flag}"
    ((result |= $?))

    return "${result}"
  )
}

run_dast() {
  local -i result=0

  pre_cleanup
  ((result |= $?))

  sanitizer "${F_BINARY}"
  ((result |= $?))

  return "${result}"
}

# Control flow logic

run_dast
exit "${?}"
