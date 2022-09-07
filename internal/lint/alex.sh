#!/bin/bash
#
# Perform a catch of insensitive, inconsiderate writing by running alex.

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
# readonly RC_FILE=".alexrc.yml"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/alex.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG.md)).*\.(md)$"

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
  readonly CMD="alex -q"

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
if [[ -f "${LOG_FILE}" ]]; then
  ERRORS=$(grep -i -c -E 'error|warning' "${LOG_FILE}" || true)
  readonly ERRORS

  if [[ "${ERRORS}" -ne 0 ]]; then
    exit 1
  else
    rm -f "${LOG_FILE}"
  fi
fi
