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

F_BINARY="NULL"
while getopts 'b:' flag; do
  case "${flag}" in
    b) F_BINARY="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly F_BINARY

# Internal functions

analyzer() {
  local -r cmd="valgrind -s --tool=memcheck --log-file=${LOG_FILE} ./${F_BINARY}"

  (
    cd "${PATH_ROOT_DIR}" || return 1

    eval "${cmd}"
  )

}

logger() {
  if ! is_file "${LOG_FILE}"; then
    return 0
  fi

  local -i errors=0
  errors=$(grep -i -c -E 'ERROR SUMMARY' "${LOG_FILE}" || true)
  if ((errors != 0)); then
    return 1
  fi

  remove_file "${LOG_FILE}"

  return 0
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
