#!/bin/bash
#
# Library for utility actions.

########################
# Add apt repository to package dependencies.
# Arguments:
#   $1 - repo
# Returns:
#   Boolean
#########################
add_apt_ppa() {
  local repo="${1:?repo is missing}"

  local -i result=0
  if ! grep -q "${repo}" /etc/apt/sources.list; then
    sudo add-apt-repository -y "${repo}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Install apt package dependencies.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
install_apt() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! command -v "${package}" &>/dev/null; then
    sudo apt install -y -qqq "${package}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Update apt package dependencies.
# Arguments:
#   None
# Returns:
#   None
#########################
update_apt() {
  sudo apt update -qqq
}

########################
# Cleanup apt package dependencies.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
cleanup_apt() {
  local -i result=0

  sudo apt install -y -f -qqq
  ((result |= $?))

  sudo apt autoremove -y -qqq
  ((result |= $?))

  sudo apt clean -qqq
  ((result |= $?))

  sudo rm -rf /var/lib/apt/lists/*
  ((result |= $?))

  return "${result}"
}

########################
# Install pip package dependencies.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
install_pip() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! command -v "${package}" &>/dev/null; then
    sudo pip install -q "${package}"
    ((result = $?))
  fi

  return "${result}"
}

########################
# Install npm package dependencies.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
install_npm() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! npm list "${package}" -g --depth=0 &>/dev/null; then
    sudo npm i --silent -g "${package}"@latest
    ((result |= $?))
  fi

  return "${result}"
}

########################
# Cleanup npm package dependencies.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
cleanup_npm() {
  local -i result=0

  npm cache clean --force --silent
  ((result |= $?))

  return "${result}"
}
