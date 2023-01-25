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

F_PATH="NULL"
while getopts 'p:' flag; do
  case "${flag}" in
    p) F_PATH="${OPTARG}" ;;
    *) ;;
  esac
done
readonly F_PATH

# Constant variables

readonly -a SCRIPTS=(
  trivy_sbom
  trivy_license
  trivy_vulnerability
)

# Internal functions

initialize_logs() {
  local log_dir
  log_dir="$(git_root_dir)/logs/security"
  local regex_patterns="^.*\.(log)$"

  if ! util_empty_dir "${log_dir}"; then
    find "${log_dir}" -type f -regextype posix-egrep -regex "${regex_patterns}" -delete
  fi

  fs_create_dir "${log_dir}"

  return "${STATUS_SUCCESS}"
}

analyze() {
  local script="${1:?script is missing}"
  local f_path="${2:?path is missing}"

  local -i retval=0

  chmod +x "${script}.sh"
  ./"${script}.sh" -p "${f_path}"
  ((retval = $?))

  log_message "security - scan" "${script}" "${retval}"

  if ((retval == STATUS_SKIP)) || ((retval == STATUS_WARNING)); then
    return "${STATUS_SUCCESS}"
  fi

  return "${retval}"
}

run_security() {
  local -a scripts=("$@")

  initialize_logs

  (
    local -i retval=0

    cd "$(fs_sript_dir)/../security" || return "${STATUS_ERROR}"

    for script in "${scripts[@]}"; do
      analyze "${script}" "${F_PATH}"
      ((retval |= $?))
    done

    return "${retval}"
  )
}

# Control flow logic

run_security "${SCRIPTS[@]}"
exit "${?}"
