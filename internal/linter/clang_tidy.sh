#!/bin/bash
#
# Perform checks of c/c++ files by running clang-tidy.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh
. ./../../scripts/utils/util.sh

# Constant variables

PATH_ROOT_DIR="$(git_root_dir)"
readonly PATH_ROOT_DIR
readonly PATH_COMPILE_COMMANDS_DB="${PATH_ROOT_DIR}/build/cmake/build"
# readonly RC_FILE=".clang-tidy"
# readonly RC_IGNORE_FILE=".clang-tidy-ignore"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/linter/clang-tidy.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG.md)).*\.(h|hpp|hxx|c|cc|cpp|cxx)$"

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
  local -a filepaths

  # Get files
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

  # Run linter
  local -r cmd="clang-tidy --fix -p=${PATH_COMPILE_COMMANDS_DB} ${filepaths}"

  (
    cd "${PATH_ROOT_DIR}" || return "${STATUS_ERROR}"

    eval "${cmd}"
  ) &>"${LOG_FILE}"

  return "${STATUS_SUCCESS}"
}

logger() {
  if ! util_exists_file "${LOG_FILE}"; then
    return "${STATUS_SUCCESS}"
  fi

  local -i errors=0
  errors=$(grep -c "error:" "${LOG_FILE}" || true)
  if ((errors != 0)); then
    return "${STATUS_ERROR}"
  fi

  local -i warnings=0
  warnings=$(grep -c "warning:" "${LOG_FILE}" || true)
  if ((warnings != 0)); then
    return "${STATUS_WARNING}"
  fi

  fs_remove_file "${LOG_FILE}"

  return "${STATUS_SUCCESS}"
}

run_clang_tidy() {
  local -i result=0

  analyzer
  ((result |= $?))

  logger
  ((result |= $?))

  return "${result}"
}

# Control flow logic

run_clang_tidy
exit "${?}"
