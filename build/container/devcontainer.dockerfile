ARG VARIANT=jammy
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

HEALTHCHECK NONE

USER vscode
