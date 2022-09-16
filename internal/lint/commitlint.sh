#!/bin/bash
#
# Perform a conventional-changelog check of the commit messages by running commitlint.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Constant variables

PATH_ROOT_DIR="$(get_root_dir)"
readonly PATH_ROOT_DIR
# readonly RC_FILE=".commitlintrc.yml"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/commitlint.log"

# Options

L_FLAG="all"
while getopts 'l:' flag; do
  case "${flag}" in
    l) L_FLAG="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly L_FLAG

# Internal functions

analyzer() {
  local -a filepaths

  # Get files
  if [[ "${L_FLAG}" == "ci" ]]; then
    return 0
  elif [[ "${L_FLAG}" == "diff" ]]; then
    return 0
  elif [[ "${L_FLAG}" == "staged" ]]; then
    filepaths="$(get_root_dir/.git/COMMIT_EDITMSG)"
  else
    echo "error: unexpected option: ${L_FLAG}" &>"${LOG_FILE}"

    return 2
  fi

  # Run linter
  if [[ -z "${filepaths}" ]]; then
    return 255
  fi

  local -r cmd="commitlint --edit"

  (
    cd "${PATH_ROOT_DIR}" || return 1

    for filepath in "${filepaths[@]}"; do
      eval "${cmd}" "${filepath}"
    done
  ) &>"${LOG_FILE}"
}

logger() {
  local -i retval=0
  local -i errors=0

  if is_file "${LOG_FILE}"; then
    errors=$(grep -i -c -E '[1-9]{1,} problems|warnings' "${LOG_FILE}" || true)

    if ((errors != 0)); then
      ((retval |= 1))
    else
      remove_file "${LOG_FILE}"
    fi
  fi

  return "${retval}"
}

lint() {
  local -i result=0

  analyzer
  ((result |= $?))

  logger
  ((result |= $?))

  return "${result}"
}

# Control flow logic

lint
exit "${?}"
