#!/bin/bash
#
# Perform dependency setup for continuous security pipeline.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Include libraries

. ./../../scripts/utils/pkg.sh
. ./../../scripts/utils/util.sh

# Constant variables

readonly -a APT_INIT_PACKAGES=(
  wget
  apt-transport-https
  gnupg
  lsb-release
)
readonly -a APT_PACKAGES=(
  trivy
)

# Internal functions

setup_syft() {
  curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin v0.74.1
}

setup_grype() {
  curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin v0.59.1
}

setup_trivy() {
  if ! util_exists_file "/etc/apt/sources.list.d/trivy.list"; then
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
  fi
}

setup_security() {
  local -i retval=0

  pkg_install_apt_list "${APT_INIT_PACKAGES[@]}"
  ((retval |= $?))

  setup_syft
  setup_grype
  setup_trivy

  pkg_install_apt_list "${APT_PACKAGES[@]}"
  ((retval |= $?))

  pkg_cleanup_apt
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

setup_security
exit "${?}"
