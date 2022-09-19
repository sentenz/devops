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

# Options

F_LINT="NULL"
while getopts 'l:' flag; do
  case "${flag}" in
    l) F_LINT="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly F_LINT

# Constant variables

readonly -a SCRIPTS=(
  alex
  write_good
  proselint
  remark
  markdown_link_check
  # markdownlint
  codespell
  # commitlint
  cppcheck
  cpplint
  clang_tidy
  clang_format
  # scan_build
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

analyze() {
  local script="${1}"
  local l_flag="${2}"

  local -i result=0

  chmod +x "${script}.sh"
  ./"${script}.sh" -l "${l_flag}"
  ((result = $?))

  monitor "validate - ${l_flag}" "${script}" "${result}"

  if ((result == STATUS_SKIP)) || ((result == STATUS_WARNING)); then
    return "${STATUS_SUCCESS}"
  fi

  return "${result}"
}

run_linter() {
  local -a scripts=("$@")

  create_dir "$(get_root_dir)/logs/validate"

  (
    local -i result=0

    cd "$(get_sript_dir)/../linter" || return "${STATUS_ERROR}"

    for script in "${scripts[@]}"; do
      analyze "${script}" "${F_LINT}"
      ((result |= $?))
    done

    return "${result}"
  )
}

# Control flow logic

run_linter "${SCRIPTS[@]}"
exit "${?}"
