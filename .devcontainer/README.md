# `/.devcontainer`

## Dev Container

[Development Containers Images](https://github.com/devcontainers/images) published docker images for use as development containers.

> If the user wants to switch to a different devcontainer.json file after selecting one, they can do so by using the "Reopen in Container" command in the Command Palette (Ctrl+Shift+P on Windows/Linux or Cmd+Shift+P on macOS) and selecting a different devcontainer.json file.

- `/base`
  > A simple Ubuntu container with Git and other common utilities installed.

- `/cpp`
  > Develop C++ applications on Linux. Includes Debian C++ build tools.

- `/go`
  > Develop Go based applications. Includes appropriate runtime args, Go, common tools, extensions, and dependencies.

## Properties

- name
  > A name for the dev container displayed in the UI.

- image
  > The name of an image for [VS Code](https://hub.docker.com/_/microsoft-vscode-devcontainers) from [dev container images](https://github.com/devcontainers/images) repository on a container registry ([DockerHub](https://hub.docker.com/), [GitHub Container Registry](https://docs.github.com/packages/guides/about-github-container-registry), [Azure Container Registry](https://azure.microsoft.com/services/container-registry/)) that devcontainer.json supporting services / tools should use to create the dev container.

- runArgs
  > An array of [Docker CLI arguments](https://docs.docker.com/engine/reference/commandline/run/) that should be used when running the container.

- forwardPorts
  > An array of port `numbers` or `host:port` values.

- remoteUser
  > Overrides the default user that devcontainer.json supporting services tools / runs as in the container.
