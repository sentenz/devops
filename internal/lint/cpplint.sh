#!/bin/bash
#
# Perform a static analysis of the codebase by running cpplint.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Constant variables

PATH_ROOT_DIR="$(get_root_dir)"
readonly PATH_ROOT_DIR
# readonly RC_FILE="CPPLINT.cfg"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/cpplint.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG.md)).*\.(h|hpp|hxx|c|cc|cpp|cxx)$"

# Options

L_FLAG="all"
while getopts 'l:' flag; do
  case "${flag}" in
    l) L_FLAG="${OPTARG}" ;;
    *) "[error] Unexpected option: ${flag}" ;;
  esac
done
readonly L_FLAG

# Control flow logic

LIST=""
if [[ "${L_FLAG}" == "ci" ]]; then
  LIST=$(get_ci_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
elif [[ "${L_FLAG}" == "diff" ]]; then
  LIST=$(get_diff_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
elif [[ "${L_FLAG}" == "staged" ]]; then
  LIST=$(get_staged_files "${PATH_ROOT_DIR}" "${REGEX_PATTERNS}")
else
  echo "[error] unexpected option: ${L_FLAG}" &>"${LOG_FILE}"
  exit 2
fi
readonly LIST

# Run analyzer
if [[ -n "${LIST}" ]]; then
  readonly CMD="cpplint --quiet --recursive"

  (
    cd "${PATH_ROOT_DIR}" || exit

    for line in ${LIST}; do
      eval "${CMD}" "${line}"
    done
  ) &>"${LOG_FILE}"
else
  exit 255
fi

# Analyze log
if is_file_empty "${LOG_FILE}"; then
  rm -f "${LOG_FILE}"
else
  exit 1
fi
