#!/bin/bash
#
# Perform checks of markdown files by running makrdownlint.

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
# readonly RC_FILE=".markdownlint.json"
# readonly RC_IGNORE_FILE=".markdownlintignore"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/linter/markdownlint-cli2.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG\.md)).*\.(md)$"

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
    filepaths=$(git_ci_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
  elif util_equal_strings "${F_LINT}" "diff"; then
    filepaths=$(git_diff_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
  elif util_equal_strings "${F_LINT}" "staged"; then
    filepaths=$(git_staged_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
  else
    echo "error: unexpected option: ${F_LINT}" &>"${LOG_FILE}"

    return "${STATUS_ERROR}"
  fi

  if ! util_is_string "${filepaths}"; then
    return "${STATUS_SKIP}"
  fi

  # shellcheck disable=SC2068
  for filepath in ${filepaths[@]}; do
    cli_markdownlint_cli2 "${filepath}"
  done &>"${LOG_FILE}"

  return "${STATUS_SUCCESS}"
}

logger() {
  if ! util_exists_file "${LOG_FILE}"; then
    return "${STATUS_SUCCESS}"
  fi

  local -i errors=0
  errors=$(grep -i -c -E '[1-9]+ error' "${LOG_FILE}" || true)
  if ((errors != 0)); then
    return "${STATUS_WARNING}"
  fi

  fs_remove_file "${LOG_FILE}"

  return "${STATUS_SUCCESS}"
}

run_markdownlint() {
  local -i retval=0

  analyzer
  ((retval |= $?))

  logger
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

run_markdownlint
exit "${?}"
