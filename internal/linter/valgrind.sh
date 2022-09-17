#!/bin/bash
#
# Perform a dynamic analysis of the codebase by running valgirnd memcheck.

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
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/validate/valgrind.log"

PATH_BINARY="."
while getopts 'p:' flag; do
  case "${flag}" in
    p) PATH_BINARY="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly PATH_BINARY

# Internal functions

analyzer() {
  if ! is_file "${PATH_BINARY}"; then
    return 255
  fi

  local -r cmd="valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes --show-reachable=yes --error-limit=no -q --log-file=${LOG_FILE} ./${PATH_BINARY}"

  (
    cd "${PATH_ROOT_DIR}" || return 1

    eval "${cmd}"
  )

}

logger() {
  local -i result=0
  local -i errors=0

  if is_file "${LOG_FILE}"; then
    errors=$(grep -i -c -E 'ERROR SUMMARY' "${LOG_FILE}" || true)

    if ((errors != 0)); then
      ((result = 1))
    else
      remove_file "${LOG_FILE}"
    fi
  fi

  return "${result}"
}

run_valgrind() {
  local -i result=0

  analyzer
  ((result |= $?))

  logger
  ((result |= $?))

  return "${result}"
}

# Control flow logic

run_valgrind
exit "${?}"
