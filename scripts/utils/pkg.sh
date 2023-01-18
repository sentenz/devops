#!/bin/bash
#
# Library for package management actions.

source "$(dirname "${BASH_SOURCE[0]}")/log.sh"
source "$(dirname "${BASH_SOURCE[0]}")/util.sh"

########################
# Add apt repository to package dependencies.
# Arguments:
#   $1 - repo
# Returns:
#   Boolean
#########################
pkg_add_apt_ppa() {
  local repo="${1:?repo is missing}"

  local -i retval=0

  if ! grep -q "${repo}" /etc/apt/sources.list; then
    sudo add-apt-repository -y "${repo}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install apt package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_install_apt() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! command -v "${package}" &>/dev/null; then
    sudo apt install -y -qqq "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Uninstall apt package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_uninstall_apt() {
  local package="${1:?package is missing}"

  local -i retval=0

  if command -v "${package}" &>/dev/null; then
    sudo apt remove -y -qqq "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install apt package list dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
pkg_install_apt_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    pkg_update_apt

    pkg_install_apt "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "setup" "${package}" "${result}"
  done

  return "${retval}"
}

########################
# Uninstall apt package list dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
pkg_uninstall_apt_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    pkg_uninstall_apt "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "teardown" "${package}" "${result}"
  done

  return "${retval}"
}

########################
# Update apt package dependencies.
# Arguments:
#   None
# Returns:
#   None
#########################
pkg_update_apt() {
  sudo apt update -qqq
}

########################
# Cleanup apt package dependencies.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
pkg_cleanup_apt() {
  local -i retval=0

  sudo apt -f install -y -qqq
  ((retval |= $?))

  sudo apt autoremove -y -qqq
  ((retval |= $?))

  sudo apt clean -qqq
  ((retval |= $?))

  sudo rm -rf /var/lib/apt/lists/*
  ((retval |= $?))

  log_message "cleanup" "apt" "${retval}"

  return "${retval}"
}

########################
# Install pip package dependency.
# Arguments:
#   $1 - package
#   $2 - version (optional)
# Returns:
#   Boolean
#########################
pkg_install_pip() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  if ! command -v "${package}" &>/dev/null; then
    if util_is_string "${version}"; then
      sudo pip install -q "${package}==${version}"
      ((retval = $?))
    else
      sudo pip install -q "${package}"
      ((retval = $?))
    fi
  fi

  return "${retval}"
}

########################
# Uninstall pip package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_uninstall_pip() {
  local package="${1:?package is missing}"

  local -i retval=0

  if command -v "${package}" &>/dev/null; then
    sudo python -m pip uninstall -y -q "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install pip package list dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
pkg_install_pip_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    pkg_install_pip "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "setup" "${package}" "${result}"
  done

  return "${retval}"
}

########################
# Install go package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_install_go() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! command -v "${package}" &>/dev/null; then
    go install "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install go package list dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
pkg_install_go_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    # HACK(AK) https://github.com/actions/setup-go/issues/14
    export PATH="${HOME}"/go/bin:/usr/local/go/bin:"${PATH}"

    pkg_install_go "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "setup" "${package}" "${result}"
  done

  return "${retval}"
}

########################
# Install curl package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_install_curl() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! command -v "$(basename "${package}")" &>/dev/null; then
    curl -sS "${package}" | bash
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install curl package list dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
pkg_install_curl_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    export PATH="${HOME}"/.local/bin:"${PATH}"

    pkg_install_curl "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "setup" "$(basename "${package}")" "${result}"
  done

  return "${retval}"
}

########################
# Install npm package dependency.
# Arguments:
#   $1 - package
#   $2 - version (optional)
# Returns:
#   Boolean
#########################
pkg_install_npm() {
  local package="${1:?package is missing}"
  local version="${2:-}"

  local -i retval=0

  if ! npm list "${package}" -g --depth=0 &>/dev/null; then
    if util_is_string "${version}"; then
      sudo npm i --silent -g "${package}"@"${version}"
      ((retval = $?))
    else
      sudo npm i --silent -g "${package}"@latest
      ((retval = $?))
    fi
  fi

  return "${retval}"
}

########################
# Uninstall npm package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_uninstall_npm() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! npm list "${package}" -g --depth=0 &>/dev/null; then
    sudo npm uninstall --silent -g "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install npm package list dependencies.
# Arguments:
#   $@ - packages
# Returns:
#   Boolean
#########################
pkg_install_npm_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    pkg_install_npm "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "setup" "${package}" "${result}"
  done

  return "${retval}"
}

########################
# Cleanup npm package dependencies.
# Arguments:
#   None
# Returns:
#   Boolean
#########################
pkg_cleanup_npm() {
  local -i retval=0

  npm cache clean --force --silent
  ((retval = $?))

  log_message "cleanup" "npm" "${retval}"

  return "${retval}"
}
