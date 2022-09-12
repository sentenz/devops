#!/bin/bash
#
# Perform dependency setup for continuous integration pipeline.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
# -o posix: match the standard
set -uo pipefail

# Include libraries

. ./../../scripts/utils/log.sh
. ./../../scripts/utils/fs.sh
. ./../../scripts/utils/git.sh
. ./../../scripts/utils/util.sh

# Constant variables

readonly GO_DEPENDENY="https://dl.google.com/go/go1.18.linux-amd64.tar.gz"
readonly -a APT_PACKAGES=(
  software-properties-common
  build-essential
  git
  automake
  python3.8
  python-is-python3
  python3-pip
  make
  curl
  nodejs
  npm

  licensecheck
  shellcheck
  cppcheck
  clang-tools
  clang-tidy
  clang-format
  valgrind
)
readonly -a PIP_PACKAGES=(
  scan-build
  codespell
  cpplint
  cmake_format
  yamllint
)
readonly -a NPM_PACKAGES=(
  alex
  prettier
  jsonlint
  @commitlint/cli
  @commitlint/config-conventional
  @commitlint/format
  markdownlint
  markdownlint-cli
  markdown-link-check
  markdown-spellcheck
  remark-cli
  remark-preset-lint-markdown-style-guide
  remark-preset-lint-recommended
  remark-preset-lint-consistent
  remark-lint-list-item-indent
  remark-lint-maximum-line-length
  remark-lint-ordered-list-marker-value
  remark-lint-emphasis-marker
  remark-lint-strong-marker
)
readonly -a GO_PACKAGES=(
  github.com/golangci/golangci-lint/cmd/golangci-lint@latest
)
readonly -a CURL_PACKAGES=(
  "https://webinstall.dev/shfmt"
)

# Internal functions

install_go_dependency() {
  local dependency="${1:?dependency is missing}"

  name="$(basename "${dependency}")"

  local -i result=0
  if is_file "$(get_root_dir)/go.mod"; then
    if ! command -v go &>/dev/null; then
      wget "${dependency}"
      ((result |= $?))
      sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "${name}" && sudo rm -f "${name}"
      ((result |= $?))
    fi
    export PATH=/usr/local/go/bin:"${PATH}"
  fi

  monitor "setup" "${name}" "${result}"

  return "${result}"
}

install_apt_packages() {
  local -a packages=("$@")

  sudo apt update
  ((result |= $?))

  local -i result=0
  for package in "${packages[@]}"; do
    install_apt "${package}"
    ((result |= $?))

    monitor "setup" "${package}" "${result}"
  done

  return "${result}"
}

install_pip_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    install_pip "${package}"
    ((result |= $?))

    monitor "setup" "${package}" "${result}"
  done

  return "${result}"
}

install_npm_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    install_npm "${package}"
    ((result |= $?))

    monitor "setup" "${package}" "${result}"
  done

  return "${result}"
}

install_go_packages() {
  local -a packages=("$@")

  local -i result=0
  if is_file "$(get_root_dir)/go.mod"; then
    for package in "${packages[@]}"; do
      # FIXME https://github.com/actions/setup-go/issues/14
      export PATH="${HOME}"/go/bin:/usr/local/go/bin:"${PATH}"

      if ! command -v "${package}" &>/dev/null; then
        go install "${package}"
        ((result = $?))
      fi

      monitor "setup" "${package}" "${result}"
    done

    go mod vendor
  fi

  return "${result}"
}

install_curl_packages() {
  local -a packages=("$@")

  local -i result=0
  for package in "${packages[@]}"; do
    name="$(basename "${package}")"

    if ! command -v "${name}" &>/dev/null; then
      curl -sS "${package}" | bash
      ((result = $?))
      export PATH="${HOME}"/.local/bin:"${PATH}"
    fi

    monitor "setup" "${name}" "${result}"
  done

  return "${result}"
}

post_cleanup() {
  local -i result=0

  sudo apt install -y -f
  ((result |= $?))

  sudo apt autoremove -y
  ((result |= $?))

  sudo apt clean
  ((result |= $?))

  sudo rm -rf /var/lib/apt/lists/*
  ((result |= $?))

  npm cache clean --force
  ((result |= $?))

  monitor "setup" "post-cleanup" "${result}"

  return "${result}"
}

continuous_integration() {
  local -i result=0

  install_go_dependency "${GO_DEPENDENY}"
  ((result |= $?))

  install_apt_packages "${APT_PACKAGES[@]}"
  ((result |= $?))

  install_pip_packages "${PIP_PACKAGES[@]}"
  ((result |= $?))

  install_npm_packages "${NPM_PACKAGES[@]}"
  ((result |= $?))

  install_curl_packages "${CURL_PACKAGES[@]}"
  ((result |= $?))

  install_go_packages "${GO_PACKAGES[@]}"
  ((result |= $?))

  post_cleanup
  ((result |= $?))

  return "${result}"
}

# Control flow logic

continuous_integration
exit "${?}"
