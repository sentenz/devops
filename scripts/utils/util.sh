#!/bin/bash
#
# Library for utility actions.

source "$(dirname "${BASH_SOURCE[0]}")/log.sh"

########################
# Add apt repository to package dependencies.
# Arguments:
#   $1 - repo
# Returns:
#   Boolean
#########################
util_add_apt_ppa() {
  local repo="${1:?repo is missing}"

  local -i result=0
  if ! grep -q "${repo}" /etc/apt/sources.list; then
    sudo add-apt-repository -y "${repo}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Install apt package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
util_install_apt() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! command -v "${package}" &>/dev/null; then
    sudo apt install -y -qqq "${package}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Setup apt package dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
util_setup_apt_packages() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    util_update_apt

    util_install_apt "${package}"
    ((result = $?))

    log_message "setup" "${package}" "${result}"
  done

  ((retval |= "${result}"))

  return "${retval}"
}

########################
# Update apt package dependencies.
# Arguments:
#   None
# Returns:
#   None
#########################
util_update_apt() {
  sudo apt update -qqq
}

########################
# Cleanup apt package dependencies.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
util_cleanup_apt() {
  local -i result=0

  sudo apt install -y -f -qqq
  ((result |= $?))

  sudo apt autoremove -y -qqq
  ((result |= $?))

  sudo apt clean -qqq
  ((result |= $?))

  sudo rm -rf /var/lib/apt/lists/*
  ((result |= $?))

  log_message "cleanup" "apt" "${result}"

  return "${result}"
}

########################
# Install pip package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
util_install_pip() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! command -v "${package}" &>/dev/null; then
    sudo pip install -q "${package}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Setup pip package dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
util_setup_pip_packages() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    util_install_pip "${package}"
    ((result = $?))

    log_message "setup" "${package}" "${result}"
  done

  ((retval |= "${result}"))

  return "${retval}"
}

########################
# Install go package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
util_install_go() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! command -v "${package}" &>/dev/null; then
    go install "${package}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Setup go package dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
util_setup_go_packages() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    # HACK(AK) https://github.com/actions/setup-go/issues/14
    export PATH="${HOME}"/go/bin:/usr/local/go/bin:"${PATH}"

    util_install_go "${package}"
    ((result = $?))

    log_message "setup" "${package}" "${result}"
  done

  ((retval |= "${result}"))

  return "${retval}"
}

########################
# Install curl package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
util_install_curl() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! command -v "$(basename "${package}")" &>/dev/null; then
    curl -sS "${package}" | bash
    ((result = $?))
  fi

  return "${result}"
}

########################
# Setup curl package dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
util_setup_curl_packages() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    export PATH="${HOME}"/.local/bin:"${PATH}"

    util_install_curl "${package}"
    ((result = $?))

    log_message "setup" "$(basename "${package}")" "${result}"
  done

  ((retval |= "${result}"))

  return "${retval}"
}

########################
# Install npm package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
util_install_npm() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! npm list "${package}" -g --depth=0 &>/dev/null; then
    sudo npm i --silent -g "${package}"@latest
    ((result |= $?))
  fi

  return "${result}"
}

########################
# Setup npm package dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
util_setup_npm_packages() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    util_install_npm "${package}"
    ((result = $?))

    log_message "setup" "${package}" "${result}"
  done

  ((retval |= "${result}"))

  return "${retval}"
}

########################
# Cleanup npm package dependencies.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
util_cleanup_npm() {
  local -i result=0

  npm cache clean --force --silent
  ((result |= $?))

  log_message "cleanup" "npm" "${result}"

  return "${result}"
}
