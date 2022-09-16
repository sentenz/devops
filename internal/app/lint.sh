#!/bin/bash
#
# Perform lint of the codebase.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/log.sh
. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh

# Options

L_FLAG="diff"
while getopts 'l:' flag; do
  case "${flag}" in
    l) L_FLAG="${OPTARG}" ;;
    *) "error: unexpected option: ${flag}" ;;
  esac
done
readonly L_FLAG

# Constant variables

readonly -a SCRIPTS=(
  alex
  clang_format
  clang_tidy
  codespell
  # commitlint
  cppcheck
  cpplint
  dockerfilelint
  golangci_lint
  jsonlint
  licensecheck
  # markdown_link_check
  # markdownlint
  mdspell
  prettier
  # remark
  # scan_build
  shellcheck
  shfmt
  # valgrind
  yamllint
)

# Internal functions

analyze() {
  local script="${1}"
  local flag="${2}"

  local -i result=0

  chmod +x "${script}.sh"
  ./"${script}.sh" -l "${flag}"
  ((result = $?))

  monitor "validate - ${flag}" "${script}" "${result}"

  if ((result == 255)); then
    return 0
  fi

  return "${result}"
}

lint() {
  local -a scripts=("$@")

  create_dir "$(get_root_dir)/logs/validate"

  cd "$(get_sript_dir)/../lint" || exit

  local -i result=0
  for script in "${scripts[@]}"; do
    analyze "${script}" "${L_FLAG}"
    ((result |= $?))
  done

  return "${result}"
}

# Control flow logic

lint "${SCRIPTS[@]}"
exit "${?}"
