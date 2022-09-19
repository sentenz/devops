#!/bin/bash
#
# Perform sanitizer calls.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/log.sh
. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Options

F_BINARY="NULL"
while getopts 'b:' flag; do
  case "${flag}" in
    b) F_BINARY="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly F_BINARY

# Constant variables

readonly -a SCRIPTS=(
  valgrind
)

# Internal functions

analyze() {
  local script="${1}"
  local b_flag="${2}"

  local -i result=0

  chmod +x "${script}.sh"
  ./"${script}.sh" -b "${b_flag}"
  ((result = $?))

  monitor "validate - ${b_flag}" "${script}" "${result}"

  if ((result == 255)) || ((result == 254)); then
    return 0
  fi

  return "${result}"
}

run_sanitizer() {
  local -a scripts=("$@")

  create_dir "$(get_root_dir)/logs/validate"

  (
    local -i result=0

    cd "$(get_sript_dir)/../sanitizer" || return 1

    for script in "${scripts[@]}"; do
      analyze "${script}" "${F_BINARY}"
      ((result |= $?))
    done

    return "${result}"
  )
}

# Control flow logic

run_sanitizer "${SCRIPTS[@]}"
exit "${?}"