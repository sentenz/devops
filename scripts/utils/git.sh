#!/bin/bash
#
# Library for git actions.

source "$(dirname "${BASH_SOURCE[0]}")/util.sh"

########################
# Configure ownership in repository.
# Arguments:
#   None
# Returns:
#   None
#########################
git_configure_repo_ownership() {
  git config --global --add safe.directory "$(git_root_dir)"
}

########################
# Get the absolute path of the root project by command substitution.
# Arguments:
#   None
# Returns:
#   Path
#########################
git_root_dir() {
  local retval
  retval="$(git rev-parse --show-superproject-working-tree --show-toplevel | head -1)"

  echo "${retval}"
}

########################
# Check if the repository is valid.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
git_valid_repo() {
  local path
  path="$(git_root_dir)"

  if ! util_exists_dir "${path}/.git"; then
    return 1
  fi

  return 0
}

########################
# Get the current local branch name by command substitution.
# Arguments:
#   None
# Returns:
#   Branch
#########################
git_local_branch() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"

  echo "${branch}"
}

########################
# Retrieve the commit message file of the edit commit on a local Git repository by command
# substitution.
# Arguments:
#   None
# Returns:
#   File
#########################
git_local_commit() {
  local file
  file="$(git_root_dir)/.git/COMMIT_EDITMSG"

  if util_exists_file "${file}"; then
    echo "${file}"
  fi
}

########################
# Get the staged files by command substitution and, optionally, with path prefix and filtered by a
# regex pattern.
# Arguments:
#   $1 - path-prefix (optional)
#   $2 - regex-pattern (optional)
# Returns:
#   List
#########################
git_staged_files() {
  local path="${1:-}"
  local regex="${2:-}"

  local retval
  retval=$(git diff --submodule=diff --diff-filter=d --name-only --line-prefix="${path}/" --cached | grep -P "${regex}" | xargs)

  echo "${retval}"
}

########################
# Get the changed files between commits by command substitution and, optionally, with path prefix
# and filtered by a regex pattern.
# Arguments:
#   $1 - path-prefix (optional)
#   $2 - regex-pattern (optional)
# Returns:
#   List
#########################
git_diff_files() {
  local path="${1:-}"
  local regex="${2:-}"

  local retval
  retval=$(git diff --submodule=diff --diff-filter=d --name-only --line-prefix="${path}/" remotes/origin/HEAD... | grep -P "${regex}" | xargs)

  echo "${retval}"
}

########################
# Get the changed files between commits by command substitution in continuous integration pipeline
# and, optionally, with path prefix and filtered by a regex pattern.
# Arguments:
#   $1 - path-prefix (optional)
#   $2 - regex-pattern (optional)
# Returns:
#   List
#########################
git_ci_files() {
  local path="${1:-}"
  local regex="${2:-}"

  local retval
  retval=$(git diff --submodule=diff --diff-filter=d --name-only --line-prefix="${path}/" remotes/origin/main... | grep -P "${regex}" | xargs)

  echo "${retval}"
}
