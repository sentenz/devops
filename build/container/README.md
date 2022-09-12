# `/container`

- devcontainer.dockerfile
  > An container image for `.devcontainer.json` file.
  >
  > Contains the commands:
  >
  > - `ARG`: Update *VARIANT* to pick an Debian / Ubuntu version (use Debian 11/9, Ubuntu 18.04/21.04 on local arm64/Apple Silicon): debian-11, debian-10, debian-9, ubuntu-21.04, ubuntu-20.04, ubuntu-18.04.
  > - `FROM`: Set the [vs code baseImage containers](https://github.com/microsoft/vscode-dev-containers/tree/v0.195.0/containers/cpp/.devcontainer/base.Dockerfile) to use for subsequent instructions.
  >
  > NOTE The repository is mounted after the container is started. To run commands based on files of the repository use the [lifecycle](https://code.visualstudio.com/docs/remote/devcontainerjson-reference#_lifecycle-scripts) scripts in `.devcontainer.json`.
