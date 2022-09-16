#!/bin/bash
#
# Perform the validation of the codebase.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../scripts/utils/fs.sh
. ./../scripts/utils/git.sh

# Options

L_FLAG="all"
while getopts 'l:' flag; do
  case "${flag}" in
    l) L_FLAG="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly L_FLAG

# Constant variables

pre_cleanup() {
  # Cleanup previous logs
  if is_dir_empty "$(get_root_dir)/logs"; then
    return 0
  fi

  local regex_patterns="^.*\.(log)$"
  find "$(get_root_dir)/logs" -type f -regextype posix-egrep -regex "${regex_patterns}" -delete
}

lint() {
  local flag="${1}"

  cd "$(get_sript_dir)/../internal/app" || return 2

  local -i result=0
  chmod +x lint.sh
  ./lint.sh -l "${L_FLAG}"
  ((result |= $?))

  return "${result}"
}

validate() {
  local -i result=0

  pre_cleanup
  ((result |= $?))

  lint "${L_FLAG}"
  ((result |= $?))

  return "${result}"
}

# Control flow logic

validate
exit "${?}"
