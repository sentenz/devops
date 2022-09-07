#!/bin/bash
#
# Library for logging actions.

# Color palette
RESET='\033[0m'
GREEN='\033[38;5;2m'
RED='\033[38;5;1m'
YELLOW='\033[38;5;3m'
DATE="[$(date +'%Y-%m-%dT%H:%M:%S%z')]"

# Functions

########################
# Log message to stderr.
# Arguments:
#   $1 - Message to log
#########################
log() {
  printf "%b\\n" "${*}" >&2
}

########################
# Log info message.
# Arguments:
#   $1 - Message to log
#########################
info() {
  log "${DATE} ${GREEN}INFO ${RESET}\t" "${*}"
}

########################
# Log warning message.
# Arguments:
#   $1 - Message to log
#########################
warn() {
  log "${DATE} ${YELLOW}WARN ${RESET}\t" "${*}"
}

########################
# Log error message.
# Arguments:
#   $1 - Message to log
#########################
error() {
  log "${DATE} ${RED}ERROR ${RESET}\t" "${*}"
}

########################
# Monitor logging message.
# Arguments:
#   $1 - Task is running
#   $2 - Performed package
#   $3 - Status of the package
# Returns:
#   None
#########################
monitor() {
  local task="${1:?task is missing}"
  local package="${2:?package is missing}"
  local status="${3:?status is missing}"

  if ((status == 0)); then
    info "[${task}] succeeded ${package}"
  elif ((status == 255)); then
    warn "[${task}] skipped ${package}"
  else
    error "[${task}] failed ${package}"
  fi
}
