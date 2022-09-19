#!/bin/bash
#
# Perform static application security testing (SAST).

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Options

F_LINT="NULL"
while getopts 'l:' flag; do
  case "${flag}" in
    l) F_LINT="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly F_LINT

# Constant variables

pre_cleanup() {
  # Cleanup previous logs
  if is_dir_empty "$(get_root_dir)/logs"; then
    return "${STATUS_SUCCESS}"
  fi

  local regex_patterns="^.*\.(log)$"
  find "$(get_root_dir)/logs" -type f -regextype posix-egrep -regex "${regex_patterns}" -delete
}

linter() {
  local l_flag="${1:?linter flag is missing}"

  (
    local -i result=0

    cd "$(get_sript_dir)/../../internal/app" || return "${STATUS_ERROR}"

    chmod +x linter.sh
    ./linter.sh -l "${l_flag}"
    ((result |= $?))

    return "${result}"
  )
}

run_sast() {
  local -i result=0

  pre_cleanup
  ((result |= $?))

  linter "${F_LINT}"
  ((result |= $?))

  return "${result}"
}

# Control flow logic

run_sast
exit "${?}"
