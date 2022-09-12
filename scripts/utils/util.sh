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
  if ! dpkg -l "${package}" &>/dev/null; then
    sudo apt install -y -qq "${package}"
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
# Install pip package dependencies.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
install_pip() {
  local package="${1:?package is missing}"

  local -i result=0
  if ! dpkg -l "${package}" &>/dev/null; then
    sudo pip install -q "${package}"
    ((result = $?))
  fi

  return "${result}"
}
