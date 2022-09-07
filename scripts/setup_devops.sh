#!/bin/bash
#
# Perform devops environment setup.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Include libraries

. ./../scripts/utils/log.sh
. ./../scripts/utils/fs.sh
. ./../scripts/utils/git.sh

# Constant variables

readonly -a SCRIPTS=(
  continuous_integration
)

# Internal functions

call_scripts() {
  local -a scripts=("$@")

  cd "$(get_sript_dir)/pipeline" || exit

  local -i result=0
  for script in "${scripts[@]}"; do
    chmod +x "${script}.sh"
    ./"${script}.sh"
    ((result |= $?))
  done

  return "${result}"
}

initialize_githooks() {
  create_dir "$(get_root_dir)/githooks"
  find "$(get_sript_dir)/../githooks" -type f -name '*' -exec cp -n {} "$(get_root_dir)/githooks" \;
  git config core.hooksPath githooks
  chmod +x "$(get_root_dir)"/githooks/*
}

initialize_dotfiles() {
  find "$(get_sript_dir)/../dotfiles" -type f -name '.??*' -exec cp -n {} "$(get_root_dir)" \;
}

setup_devops() {
  local -i result=0

  initialize_githooks
  initialize_dotfiles

  call_scripts "${SCRIPTS[@]}"
  ((result |= $?))

  return "${result}"
}

# Control flow logic

setup_devops
exit "${?}"
