#!/bin/bash
#
# Library for git hook actions.

source "$(dirname "${BASH_SOURCE[0]}")/util.sh"

########################
# Prevent a direct push to the base branches.
# Arguments:
#   $1 - local branch
#   $@ - base branches
# Returns:
#   Boolean
#########################
hook_verify_branch_push() {
  local local_branch="${1:?local branch is missing}"
  local -a base_branches=("${@:2}")

  for branch in "${base_branches[@]}"; do
    if util_equal_strings "${branch}" "${local_branch}"; then
      cat <<END
___________________________________________________________________________________________________
Branching Strategy

Prevent a direct push to the base branches.

Noting that contributions to base branches are not compliant with the branching strategy.
Contributing to a base branch can only be made via pull requests (PR). Create a support branch
from and merge back to a base branch.

See https://sentenz.github.io/guide/internal/guideline/branching-strategies-guide.html
___________________________________________________________________________________________________
END

      return 1
    fi
  done

  return 0
}

########################
# Enforce naming convention for support branches.
# Arguments:
#   $1 - local branch
#   $@ - support branches
# Returns:
#   Boolean
#########################
hook_verify_branch_naming() {
  local local_branch="${1:?local branch is missing}"
  local -a support_branches=("${@:2}")

  pattern="^($(
    IFS=$'|'
    echo "${support_branches[*]}"
  ))\/[0-9]+[a-z0-9-]+[a-z0-9]+$"

  # shellcheck disable=SC2086
  if ! util_regex_match "${pattern}" "${local_branch}"; then
    cat <<END
___________________________________________________________________________________________________
Branching Strategy

Enforce naming convention for support branches.

There is something wrong with the name of the local branch "${local_branch}". Rename the local
branch according to the naming convention for support branches.

The naming rule is: [support-branch]/[issue-id]-[short-description].

  1. support-branch: feature, release, and fix.
  2. followed by a slash (/)
  3. issue-id: in digit(s)
  4. short-description: only lowercase letters, separated by hyphens

Example: feature/158-enforce-policy

See https://sentenz.github.io/guide/internal/guideline/branching-strategies-guide.html
___________________________________________________________________________________________________
END

    return 1
  fi

  return 0
}

########################
# Enforce coding standards and static analysis through linting and code style checks.
# Arguments:
#   $1 - executable command
# Returns:
#   Boolean
#########################
hook_code_analysis() {
  local cmd="${1:?executable command is missing}"

  local -i retval=0

  bash -c "${cmd}"
  ((retval = $?))

  if ((retval != 0)); then
    cat <<END
___________________________________________________________________________________________________
Code Analysis

Enforce coding standards and static analysis through linting and code style checks.

See https://sentenz.github.io/https://sentenz.github.io/guide/internal/about/software-analysis.html
___________________________________________________________________________________________________
END
  fi

  return "${retval}"
}

########################
# Perform software composition analysis (sca).
# Arguments:
#   $1 - executable command
# Returns:
#   Boolean
#########################
hook_composition_analysis() {
  local cmd="${1:?executable command is missing}"

  local -i retval=0

  bash -c "${cmd}"
  ((retval = $?))

  if ((retval != 0)); then
    cat <<END
___________________________________________________________________________________________________
Software Composition Analysis

Identifying and managing the open-source and third-party components used in software applications.

See https://sentenz.github.io/https://sentenz.github.io/guide/internal/about/software-analysis.html
___________________________________________________________________________________________________
END
  fi

  return "${retval}"
}

########################
# Enforce the conventional commits specification to commit messages.
# Arguments:
#   $1 - executable command
#   $2 - commit message file
# Returns:
#   Boolean
#########################
hook_verify_commit_convention() {
  local cmd="${1:?executable command is missing}"
  local commit="${2:?commit message file is missing}"

  local -i retval=0

  bash -c "${cmd}"
  ((retval = $?))

  if ((retval != 0)); then
    cat <<END
___________________________________________________________________________________________________
Commit Message Convention

Enforce the conventional commits specification to commit messages.

There is something wrong with the commit message:

  "$(cat "${commit}")"

A commit message that is compliant with Conventional Commits consists of the format:

  <type>(<scope>): <short summary>

See https://sentenz.github.io/guide/internal/guideline/commit-message-guide.html
___________________________________________________________________________________________________
END
  fi

  return "${retval}"
}

########################
# Enforce the creation of support branches from the base branches.
# Arguments:
#   $1 - local branch
#   $2 - flag checkout
#   $@ - base branches
# Returns:
#   Boolean
#########################
hook_verify_branch_context() {
  local local_branch="${1:?local branch is missing}"
  local flag_checkout="${2:?checkout flag is missing}"
  local -a base_branches=("${@:3}")

  if util_equal_strings "${flag_checkout}" "0"; then
    return 0
  fi

  parant_branch="$(git show-branch |
    sed "s/].*//" |
    grep "\*" |
    grep -v "${local_branch}" |
    head -n1 |
    sed "s/^.*\[//")"

  if ! util_is_string "${parant_branch}"; then
    return 0
  fi

  for branch in "${base_branches[@]}"; do
    if util_equal_strings "${branch}" "${parant_branch}"; then
      return 0
    fi
  done

  cat <<END
___________________________________________________________________________________________________
Branching Strategy

Enforce to create the support branches from the base branches.

Branch "${local_branch}" is created from "${parant_branch}".
Though, support branches should be created from a base branch, e.g. "${base_branches[@]}".

See https://sentenz.github.io/guide/internal/guideline/branching-strategies-guide.html
___________________________________________________________________________________________________
END

  # Skip hook trigger
  git -c core.hooksPath=/dev/null checkout "${parant_branch}"

  return 1
}
