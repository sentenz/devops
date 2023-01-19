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
. ./../../scripts/utils/util.sh

# Options

F_BINARY="NULL"
while getopts 'b:' flag; do
  case "${flag}" in
    b) F_BINARY="${OPTARG}" ;;
    *) ;;
  esac
done
readonly F_BINARY

# Constant variables

readonly -a SCRIPTS=(
  valgrind
)

# Internal functions

initialize_logs() {
  local log_dir
  log_dir="$(git_root_dir)/logs/sanitizer"
  local regex_patterns="^.*\.(log)$"

  if ! util_empty_dir "${log_dir}"; then
    find "${log_dir}" -type f -regextype posix-egrep -regex "${regex_patterns}" -delete
  fi

  fs_create_dir "${log_dir}"

  return "${STATUS_SUCCESS}"
}

analyze() {
  local script="${1:?script is missing}"
  local f_binary="${2:?binary is missing}"

  local -i retval=0

  chmod +x "${script}.sh"
  ./"${script}.sh" -b "${f_binary}"
  ((retval = $?))

  log_message "sanitizer - ${f_binary}" "${script}" "${retval}"

  if ((retval == STATUS_SKIP)) || ((retval == STATUS_WARNING)); then
    return "${STATUS_SUCCESS}"
  fi

  return "${retval}"
}

run_sanitizer() {
  local -a scripts=("$@")

  initialize_logs

  (
    local -i retval=0

    cd "$(fs_sript_dir)/../sanitizer" || return "${STATUS_ERROR}"

    for script in "${scripts[@]}"; do
      analyze "${script}" "${F_BINARY}"
      ((retval |= $?))
    done

    return "${retval}"
  )
}

# Control flow logic

run_sanitizer "${SCRIPTS[@]}"
exit "${?}"
