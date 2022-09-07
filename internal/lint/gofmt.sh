#!/bin/bash
#
# Perform a formatting of the go code base by running gofmt.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Constant variables

PATH_ROOT_DIR="$(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)"
readonly PATH_ROOT_DIR
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/gofmt.log"
readonly REGEX_PATTERNS="^(?!.*\/?!*(\.git|vendor|external|CHANGELOG.md)).*\.(go)$"

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
readonly LIST

# Run analyzer
if [[ -n "${LIST}" ]]; then
  readonly CMD="gofmt -s -l -d"

  (
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
