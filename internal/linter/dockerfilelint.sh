#!/bin/bash
#
# Perform checks of docker files by running dockerfilelint.

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
# readonly RC_FILE=".dockerfilelintrc"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/dockerfilelint.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG.md)).*(Dockerfile)$"

# Options

F_LINT="NULL"
while getopts 'l:' flag; do
  case "${flag}" in
    l) F_LINT="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly F_LINT

# Internal functions

analyzer() {
  local -a filepaths

  # Get files
  if [[ "${F_LINT}" == "ci" ]]; then
    filepaths=$(get_ci_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
  elif [[ "${F_LINT}" == "diff" ]]; then
    filepaths=$(get_diff_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
  elif [[ "${F_LINT}" == "staged" ]]; then
    filepaths=$(get_staged_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
  else
    echo "error: unexpected option: ${F_LINT}" &>"${LOG_FILE}"

    return 2
  fi

  if [[ -z "${filepaths}" ]]; then
    return 255
  fi

  # Run linter
  local -r cmd="dockerfilelint"

  (
    cd "${PATH_ROOT_DIR}" || return 1

    for filepath in "${filepaths[@]}"; do
      eval "${cmd}" "${filepath}"
    done
  ) &>"${LOG_FILE}"

  return 0
}

logger() {
  if ! is_file "${LOG_FILE}"; then
    return 0
  fi

  local -i errors=0
  errors=$(grep -i -c -E 'Possible Bug|Optimization|Clarity' "${LOG_FILE}" || true)
  if ((errors != 0)); then
    return 1
  fi

  remove_file "${LOG_FILE}"

  return 0
}

run_dockerfilelint() {
  local -i result=0

  analyzer
  ((result |= $?))

  logger
  ((result |= $?))

  return "${result}"
}

# Control flow logic

run_dockerfilelint
exit "${?}"
