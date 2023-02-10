#!/bin/bash
#
# Library for utility based on conditional expression.

########################
# Verify if string is empty.
# Arguments:
#   $1 - string
# Returns:
#   Boolean - true if the length of string is non-zero
#########################
util_is_string() {
  local string="${1}"

  if [[ -z "${string}" ]]; then
    return 1
  fi

  return 0
}

########################
# Verify if strings are equal.
# Arguments:
#   $1 - string1
#   $2 - string2
# Returns:
#   Boolean - true if the strings are equal
#########################
util_equal_strings() {
  local string1="${1}"
  local string2="${2}"

  if [[ "${string1}" != "${string2}" ]]; then
    return 1
  fi

  return 0
}

########################
# Verify if directory exist.
# Arguments:
#   $1 - directory
#   $2 - owner
# Returns:
#   Boolean - true if the directory exists
#########################
util_exists_dir() {
  local dir="${1}"

  if [[ ! -d "${dir}" ]]; then
    return 1
  fi

  return 0
}

########################
# Verify if directory is empty.
# Arguments:
#   $1 - directory
#   $2 - owner
# Returns:
#   Boolean - true if the directory is empty
#########################
util_empty_dir() {
  local dir="${1:?directory is missing}"

  if [[ -n "$(ls -A "${dir}")" ]]; then
    return 1
  fi

  return 0
}

########################
# Verify if file exists.
# Arguments:
#   $1 - filename
# Returns:
#   Boolean - true if file exists
#########################
util_exists_file() {
  local file="${1}"

  if [[ ! -f "${file}" ]]; then
    return 1
  fi

  return 0
}

########################
# Verify if file is empty.
# Arguments:
#   $1 - filename
# Returns:
#   Boolean - true if file is empty
#########################
util_empty_file() {
  local file="${1}"

  if [[ -s "${file}" ]]; then
    return 1
  fi

  return 0
}

########################
# Perform a regex match against the specified pattern.
# Arguments:
#   $1 - pattern (must be unquoted)
#   $2 - string
# Returns:
#   Boolean - true if the match
#########################
util_regex_match() {
  local pattern="${1}"
  local string="${2}"

  if [[ ! "${string}" =~ $pattern ]]; then
    return 1
  fi

  return 0
}
