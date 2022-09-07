# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.195.0/containers/cpp/.devcontainer/base.Dockerfile
# [Choice] Debian / Ubuntu version (use Debian 11/9, Ubuntu 18.04/21.04 on local arm64/Apple Silicon): debian-11, debian-10, debian-9, ubuntu-21.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT=ubuntu-21.04
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# NOTE Repository mounted after container is started.
# To execute commands based on files of the repository use the Lifecycle scripts in `.devcontainer.json`
# See (https://code.visualstudio.com/docs/remote/devcontainerjson-reference#_lifecycle-scripts)
