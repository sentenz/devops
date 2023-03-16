#!/bin/bash
#
# Library for cli actions.

source "$(dirname "${BASH_SOURCE[0]}")/util.sh"

########################
# Checks if the commit messages meet the conventional commit format.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_commitlint() {
  local file="${1:?file is missing}"

  commitlint --edit "${file}"
}

########################
# A static analysis tool with suggestions for bash/sh scripts.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_shellcheck() {
  local file="${1:?file is missing}"

  shellcheck -s bash "${file}"
}

########################
# Catch insensitive, inconsiderate writing.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_alex() {
  local file="${1:?file is missing}"

  alex -q "${file}"
}

########################
# A tool to format C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C# code.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_clang_format() {
  local file="${1:?file is missing}"

  clang-format --dry-run "${file}"
}

########################
# Check code for common misspellings.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_codespell() {
  local file="${1:?file is missing}"

  codespell "${file}"
}

########################
# A clang-based C++ static analysis tool to fixing typical programming errors, style violations,
# interface misuse.
# Arguments:
#   $1 - file
#   $2 - database
# Returns:
#   Result
#########################
cli_clang_tidy() {
  local file="${1:?file is missing}"
  local database="${2:-}"

  clang-tidy --fix -p="${database}" "${file}"
}

########################
# Static analysis of C/C++ code.
# Arguments:
#   $1 - file
#   $2 - resource
# Returns:
#   Result
#########################
cli_cppcheck() {
  local file="${1:?file is missing}"
  local resource="${2:-}"

  if util_is_string "${resource}"; then
    cppcheck --enable=warning --suppressions-list="${resource}" --template='[{file}:{line}]:({severity}),{id},{message}' --force -q "${file}"
  else
    cppcheck --enable=warning --template='[{file}:{line}]:({severity}),{id},{message}' --force -q "${file}"
  fi
}

########################
# Static nalysis of C/C++ files for style issues following Google's C++ style guide.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_cpplint() {
  local file="${1:?file is missing}"

  cpplint --quiet "${file}"
}

########################
# An opinionated Dockerfile linter for common traps, mistakes and helps enforce best practices.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_dockerfilelint() {
  local file="${1:?file is missing}"

  dockerfilelint "${file}"
}

########################
# A fast Go linters runner.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_golangci_lint() {
  local file="${1:?file is missing}"

  # FIXME(AK) https://github.com/actions/setup-go/issues/14
  export PATH="${HOME}"/go/bin:/usr/local/go/bin:"${PATH}"

  golangci-lint run --fast "${file}"
}

########################
# A JSON parser and validator.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_jsonlint() {
  local file="${1:?file is missing}"

  jsonlint -q -p -c "${file}"
}

########################
# A license checker for source files.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_licensecheck() {
  local file="${1:?file is missing}"

  licensecheck --copyright --deb-machine --lines 0 "${file}"
}

########################
# Checks that all of the hyperlinks in a markdown text to determine if they are alive or dead.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_markdown_link_check() {
  local file="${1:?file is missing}"

  markdown-link-check -r -q "${file}"
}

########################
# A fast, flexible, configuration-based command-line interface for linting Markdown/CommonMark
# files with the markdownlint library.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_markdownlint_cli2() {
  local file="${1:?file is missing}"

  markdownlint-cli2 "${file}"
}

########################
# An opinionated code formatter.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_prettier() {
  local file="${1:?file is missing}"

  prettier -l "${file}"
}

########################
# A linter for prose.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_proselint() {
  local file="${1:?file is missing}"

  proselint "${file}"
}

########################
# A shell parser, formatter, and interpreter with bash support.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_shfmt() {
  local file="${1:?file is missing}"

  shfmt -d -i 2 -ci "${file}"
}

########################
# A shell parser, formatter, and interpreter with bash support.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_write_good() {
  local file="${1:?file is missing}"

  write-good --parse "${file}"
}

########################
# A linter for YAML files.
# Arguments:
#   $1 - file
# Returns:
#   Result
#########################
cli_yamllint() {
  local file="${1:?file is missing}"

  yamllint -s "${file}"
}

########################
# An instrumentation framework for building dynamic analysis tools.
# Arguments:
#   $1 - binary
#   $2 - log
# Returns:
#   Result
#########################
cli_valgrind() {
  local binary="${1:?binary is missing}"
  local log="${2:-}"

  if util_is_string "${log}"; then
    valgrind --log-file="${log}" "${binary}"
  else
    valgrind "${binary}"
  fi
}

########################
# Generating a SBOM from container images and filesystems.
# Arguments:
#   $1 - path
#   $2 - log
# Returns:
#   Result
#########################
cli_syft() {
  local path="${1:?path is missing}"
  local log="${2:?log is missing}"

  syft -q -o spdx="${log}" "${path}"
}

########################
# A SBOM vulnerability scanner for container images and filesystems.
# Arguments:
#   $1 - path
#   $2 - log
# Returns:
#   Result
#########################
cli_grype() {
  local path="${1:?path is missing}"
  local log="${2:?log is missing}"

  grype -q --file "${log}" sbom:"${path}"
}

########################
# Find OS packages and software dependencies with SBOM in containers, Kubernetes, code
# repositories, and clouds.
# Arguments:
#   $1 - path
#   $2 - log
# Returns:
#   Result
#########################
cli_trivy() {
  local path="${1:?path is missing}"
  local log="${2:?log is missing}"

  trivy -q fs --format spdx -o "${log}" "${path}"
}

########################
# Scan SBOM for vulnerabilities.
# Arguments:
#   $1 - path
#   $2 - log
# Returns:
#   Result
#########################
cli_trivy_sbom() {
  local path="${1:?path is missing}"
  local log="${2:?log is missing}"

  trivy -q sbom -o "${log}" "${path}"
}

########################
# Scans for license files and offers an opinionated view on the risk associated with the license.
# Arguments:
#   $1 - path
#   $2 - log
# Returns:
#   Result
#########################
cli_trivy_license() {
  local path="${1:?path is missing}"
  local log="${2:?log is missing}"

  trivy -q fs --scanners license --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL --license-full --format json -o "${log}" "${path}"
}

########################
# Find vulnerabilities in software projects.
# Arguments:
#   $1 - path
#   $2 - log
# Returns:
#   Result
#########################
cli_trivy_vulnerability() {
  local path="${1:?path is missing}"
  local log="${2:?log is missing}"

  trivy -q fs --scanners vuln,secret,config --format json -o "${log}" "${path}"
}
