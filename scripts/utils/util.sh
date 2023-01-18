#!/bin/bash
#
# Library for utility actions.

########################
# Verify string based on conditional expression.
# Arguments:
#   $1 - string
# Returns:
#   Boolean - True if the length of string is non-zero.
#########################
util_isStringEmpty() {
  local string="${1}"

  if [[ -n "${string}" ]]; then
    return 1
  fi

  return 0
}
