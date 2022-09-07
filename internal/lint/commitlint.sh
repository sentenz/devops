#!/bin/bash
#
# Perform a conventional-changelog check of the commit messages by running commitlint.

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
readonly RC_FILE=".commitlintrc.js"
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/commitlint.log"

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
  LIST=$(commitlint --from "$(git rev-parse --abbrev-ref remotes/origin/main)" --to "$(git rev-parse --abbrev-ref HEAD)" --config "${PATH_ROOT_DIR}/${RC_FILE}")
elif [[ "${L_FLAG}" == "diff" || "${L_FLAG}" == "repo" ]]; then
  LIST=$(commitlint --from "$(git rev-parse --abbrev-ref remotes/origin/HEAD)" --to "$(git rev-parse --abbrev-ref HEAD)" --config "${PATH_ROOT_DIR}/${RC_FILE}")
elif [[ "${L_FLAG}" == "staged" ]]; then
  # TODO(AK) currently husky commit-msg and run_commitlint.sh do not work together
  #EDITMSG_FILE=$(git rev-parse --git-path COMMIT_EDITMSG)
  #if [[ -z "${EDITMSG_FILE}" ]]; then
  #  exit 255
  #fi
  #LIST=$(commitlint --edit --config "${PATH_ROOT_DIR}/${RC_FILE}")
  exit 255
elif [[ "${L_FLAG}" == "all" ]]; then
  LIST=$(commitlint --to "$(git rev-parse --short HEAD)" --config "${PATH_ROOT_DIR}/${RC_FILE}")
else
  echo "[error] Unexpected option: ${L_FLAG}" &>"${LOG_FILE}"
  exit 2
fi
readonly LIST

# Run analyzer
if [[ -n "${LIST}" ]]; then
  echo "${LIST}" &>"${LOG_FILE}"
else
  exit 255
fi

# Analyze log
if [[ -f "${LOG_FILE}" ]]; then
  PROBLEMS=$(grep -i -c -E '[1-9]{1,} problems' "${LOG_FILE}" || true)
  readonly PROBLEMS
  WARNINGS=$(grep -i -c -E '[1-9]{1,} warnings' "${LOG_FILE}" || true)
  readonly WARNINGS

  if [[ "${PROBLEMS}" -ne 0 || "${WARNINGS}" -ne 0 ]]; then
    exit 1
  else
    rm -f "${LOG_FILE}"
  fi
fi
