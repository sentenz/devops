#!/bin/bash
#
# Perform checks of commit messages by running commitlint.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh
. ./../../scripts/utils/util.sh
. ./../../scripts/utils/cli.sh

# Constant variables

PATH_ROOT_DIR="$(git_root_dir)"
readonly PATH_ROOT_DIR
# readonly RC_FILE=".commitlintrc.yml"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/linter/commitlint.log"

# Options

F_LINT="NULL"
while getopts 'l:' flag; do
  case "${flag}" in
    l) F_LINT="${OPTARG}" ;;
    *) ;;
  esac
done
readonly F_LINT

# Internal functions

analyzer() {
  cd "${PATH_ROOT_DIR}" || return "${STATUS_ERROR}"

  local -a filepaths

  if util_equal_strings "${F_LINT}" "ci"; then
    filepaths="$(git_local_commit)"
  elif util_equal_strings "${F_LINT}" "diff"; then
    return "${STATUS_SKIP}"
  elif util_equal_strings "${F_LINT}" "staged"; then
    filepaths="$(git_local_commit)"
  else
    echo "error: unexpected option: ${F_LINT}" &>"${LOG_FILE}"

    return "${STATUS_ERROR}"
  fi

  if ! util_is_string "${filepaths}"; then
    return "${STATUS_SKIP}"
  fi

  # shellcheck disable=SC2068
  for filepath in ${filepaths[@]}; do
    cli_commitlint "${filepath}"
  done &>"${LOG_FILE}"

  return "${STATUS_SUCCESS}"
}

logger() {
  if ! util_exists_file "${LOG_FILE}"; then
    return "${STATUS_SUCCESS}"
  fi

  local -i errors=0
  errors=$(grep -i -c -E '[1-9]{1,} problems|warnings' "${LOG_FILE}" || true)
  if ((errors != 0)); then
    return "${STATUS_ERROR}"
  fi

  fs_remove_file "${LOG_FILE}"

  return "${STATUS_SUCCESS}"
}

run_commitlint() {
  local -i retval=0

  analyzer
  ((retval |= $?))

  logger
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

run_commitlint
exit "${?}"
