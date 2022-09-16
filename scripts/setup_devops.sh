#!/bin/bash
#
# Perform devops environment setup.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../scripts/utils/fs.sh
. ./../scripts/utils/git.sh

# Constant variables

readonly -a SCRIPTS=(
  setup_continuous_integration.sh
)

# Internal functions

initialize_scripts() {
  if is_dir "$(get_sript_dir)/pipeline"; then
    copy_files "$(get_sript_dir)/pipeline" "$(get_root_dir)/scripts"
  fi

  if is_dir "$(get_sript_dir)/utils"; then
    copy_files "$(get_sript_dir)/utils" "$(get_root_dir)/scripts"
  fi
}

initialize_githooks() {
  if is_dir "$(get_sript_dir)/../githooks"; then
    copy_files "$(get_sript_dir)/../githooks" "$(get_root_dir)"
    chmod +x "$(get_root_dir)"/githooks/*
    git config core.hooksPath githooks
  fi
}

initialize_dotfiles() {
  if is_dir "$(get_sript_dir)/../dotfiles"; then
    copy_files "$(get_sript_dir)/../dotfiles" "$(get_root_dir)"
    copy_files "$(get_sript_dir)/../dotfiles/." "$(get_root_dir)"
  fi
}

initialize_pipelines() {
  if is_dir "$(get_sript_dir)/../.azure"; then
    copy_files "$(get_sript_dir)/../.azure" "$(get_root_dir)"
  fi

  if is_dir "$(get_sript_dir)/../.github"; then
    copy_files "$(get_sript_dir)/../.github" "$(get_root_dir)"
  fi
}

initialize_container() {
  if is_dir "$(get_sript_dir)/../.devcontainer"; then
    copy_files "$(get_sript_dir)/../.devcontainer" "$(get_root_dir)"
  fi

  if is_dir "$(get_sript_dir)/../build/container"; then
    copy_files "$(get_sript_dir)/../build/container" "$(get_root_dir)/build"
  fi
}

initialize_merge() {
  if is_file "$(get_sript_dir)/../Makefile"; then
    merge_file "$(get_sript_dir)/../Makefile" "$(get_root_dir)/Makefile"
  fi

  if is_file "$(get_sript_dir)/../.vscode/extensions.json"; then
    merge_file "$(get_sript_dir)/../.vscode/extensions.json" "$(get_root_dir)/.vscode/extensions.json"
  fi
}

run_scripts() {
  local -a scripts=("$@")

  cd "$(get_sript_dir)/pipeline" || exit

  local -i result=0
  for script in "${scripts[@]}"; do
    chmod +x "${script}"
    ./"${script}"
    ((result |= $?))
  done

  return "${result}"
}

setup_devops() {
  local -i result=0

  run_scripts "${SCRIPTS[@]}"
  ((result |= $?))

  initialize_scripts
  initialize_dotfiles
  initialize_githooks
  initialize_pipelines
  initialize_container
  initialize_merge

  return "${result}"
}

# Control flow logic

setup_devops
exit "${?}"
