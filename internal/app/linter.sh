#!/bin/bash
#
# Perform linter calls.

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

F_LINT="NULL"
while getopts 'l:' flag; do
  case "${flag}" in
    l) F_LINT="${OPTARG}" ;;
    *) ;;
  esac
done
readonly F_LINT

# Constant variables

readonly -a SCRIPTS=(
  alex
  write_good
  proselint
  codespell
  markdown_link_check
  markdownlint_cli2
  commitlint
  cppcheck
  cpplint
  clang_tidy
  clang_format
  golangci_lint
  dockerfilelint
  licensecheck
  shellcheck
  shfmt
  prettier
  jsonlint
  yamllint
)

# Internal functions

initialize_logs() {
  local log_dir
  log_dir="$(git_root_dir)/logs/linter"
  local regex_patterns="^.*\.(log)$"

  if util_exists_dir "${log_dir}"; then
    find "${log_dir}" -type f -regextype posix-egrep -regex "${regex_patterns}" -delete
  fi

  fs_create_dir "${log_dir}"

  return "${STATUS_SUCCESS}"
}

analyze() {
  local script="${1}"
  local f_lint="${2}"

  local -i retval=0

  chmod +x "${script}.sh"
  ./"${script}.sh" -l "${f_lint}"
  ((retval = $?))

  log_message "linter - ${f_lint}" "${script}" "${retval}"

  if ((retval == STATUS_SKIP)) || ((retval == STATUS_WARNING)); then
    return "${STATUS_SUCCESS}"
  fi

  return "${retval}"
}

run_linter() {
  local -a scripts=("$@")

  initialize_logs

  (
    local -i retval=0

    cd "$(fs_sript_dir)/../linter" || return "${STATUS_ERROR}"

    for script in "${scripts[@]}"; do
      analyze "${script}" "${F_LINT}"
      ((retval |= $?))
    done

    return "${retval}"
  )
}

# Control flow logic

run_linter "${SCRIPTS[@]}"
exit "${?}"
