#!/bin/bash
#
# Perform a interactive security analysis of the codebase by running trivy sbom.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh
. ./../../scripts/utils/util.sh
. ./../../scripts/utils/cli.sh

# Constant variables

PATH_ROOT_DIR="$(git_root_dir)"
readonly PATH_ROOT_DIR
readonly LOG_FILE="${PATH_ROOT_DIR}/logs/security/trivy-sbom.log"

F_PATH="NULL"
while getopts 'p:' flag; do
  case "${flag}" in
    p) F_PATH="${OPTARG}" ;;
    *) ;;
  esac
done
readonly F_PATH

# Internal functions

analyzer() {
  cd "${PATH_ROOT_DIR}" || return "${STATUS_ERROR}"

  cli_trivy_sbom "${F_PATH}" "${LOG_FILE}"
}

logger() {
  if ! util_exists_file "${LOG_FILE}"; then
    return "${STATUS_ERROR}"
  fi

  return "${STATUS_SUCCESS}"
}

run_trivy_sbom() {
  local -i retval=0

  analyzer
  ((retval |= $?))

  logger
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

run_trivy_sbom
exit "${?}"
