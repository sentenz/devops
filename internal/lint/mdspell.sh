#!/bin/bash
#
# Perform a check of the markdown spelling by running mdspell.

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
readonly RC_FILE=".spelling"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/mdspell.log"
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
  readonly SORT="sort < ${PATH_ROOT_DIR}/${RC_FILE} | sort | uniq | tee ${RC_FILE}.tmp > /dev/null && mv ${RC_FILE}.tmp ${PATH_ROOT_DIR}/${RC_FILE}"
  readonly CMD="mdspell -n -a -r -d --en-us --en-gb '!**/node_modules/**/*.md' '!**/vendor/**/*.md' '!**/.github/**/*.md' '!**/translations/**/*.md'"

  eval "${SORT}"

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
  ERRORS=$(grep -i -c -E 'spelling errors found' "${LOG_FILE}" || true)
  readonly ERRORS

  if [[ "${ERRORS}" -ne 0 ]]; then
    exit 1
  else
    rm -f "${LOG_FILE}"
  fi
fi
