#!/bin/bash
#
# Perform a check of yaml files by running yamllint.

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
# readonly RC_FILE=".yamllint.yml"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/yamllint.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG.md)).*\.(yml|yaml)$"

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
  LIST=$(git diff --submodule=diff --diff-filter=d --name-only --line-prefix="${PATH_ROOT_DIR}/" remotes/origin/main... | grep -P "${REGEX_PATTERNS}" | xargs)
elif [[ "${L_FLAG}" == "diff" ]]; then
  LIST=$(git diff --submodule=diff --diff-filter=d --name-only --line-prefix="${PATH_ROOT_DIR}/" remotes/origin/HEAD... | grep -P "${REGEX_PATTERNS}" | xargs)
elif [[ "${L_FLAG}" == "staged" ]]; then
  LIST=$(git diff --submodule=diff --diff-filter=d --name-only --line-prefix="${PATH_ROOT_DIR}/" --cached | grep -P "${REGEX_PATTERNS}" | xargs)
elif [[ "${L_FLAG}" == "repo" ]]; then
  LIST=$(git ls-tree --full-tree -r --name-only HEAD | grep -P "${REGEX_PATTERNS}" | xargs -r printf -- "${PATH_ROOT_DIR}/%s ")
elif [[ "${L_FLAG}" == "all" ]]; then
  LIST=$(git ls-files --recurse-submodules | grep -P "${REGEX_PATTERNS}" | xargs -r printf -- "${PATH_ROOT_DIR}/%s ")
else
  echo "[error] Unexpected option: ${L_FLAG}" &>"${LOG_FILE}"
  exit 2
fi
#readonly LIST

# Run analyzer
if [[ -n "${LIST}" ]]; then
  readonly CMD="yamllint --no-warnings"

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
  ERRORS=$(grep -c "error" "${LOG_FILE}" || true)
  readonly ERRORS
  WARNINGS=$(grep -c "warning" "${LOG_FILE}" || true)
  readonly WARNINGS

  if [[ "${ERRORS}" -ne 0 || "${WARNINGS}" -ne 0 ]]; then
    exit 1
  else
    rm -f "${LOG_FILE}"
  fi
fi
