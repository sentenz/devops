# DevOps

A service for DevOps operations.

- [1. Setup](#1-setup)
- [2. Install](#2-install)
- [2. Usage](#2-usage)
  - [2.1. Git Hooks](#21-git-hooks)
  - [2.2. Continuous Pipelines](#22-continuous-pipelines)
  - [2.3. Code Analysis](#23-code-analysis)

Supported operations:

- [x] Code Analysis
  > Safety-related analysis, code quality analysis, syntax style review tools, or dead code detection tools.
  >
  > - [Linter](internal/README.md#linter)
  > - [Sanitizer](internal/README.md#sanitizer)
  > - [Security](internal/README.md#security)

- [x] Continuous Pipelines
  > Pipeline stages in an automated software development and deployment flow.
  >
  > - [Azure Pipelines](.azure/README.md)
  > - [GitHub Actions workflows](.github/workflows/README.md)

- [x] Git Hooks
  > [Hooks](githooks/README.md) are used by Git to trigger actions at certain points in git command.

- [x] Containers
  >  Ready to use container [templates](build/container/README.md).

- [x] Makefile
  > Collection of [make targets](Makefile) used for this DevOps service repository.

## 1. Setup

Integrate the DevOps service repository into a base repository with `git submodule` dependency or any other appropriate method.

Run the following command to setup the DevOps service into the base repository:

```bash
cd path/to/devops/scripts 
chmod +x setup.sh
./setup.sh
```

## 2. Install

Add, update or remove DevOps service as Git submodule.

> NOTE Modify the [Makefile](Makefile) to meet the requirements of a base repository:
>
> - URL_DEVOPS := `<url>`
> - PATH_DEVOPS := `<relative-path>`

- Add Git submodule

   ```bash
   make setup-submodule
   ```

- Update Git submodules

   ```bash
   make update-submodule
   ```

- Remove Git submodules

   ```bash
   make teardown-submodule
   ```

## 2. Usage

The commands of the initialized DevOps service are available as `make <target>` in the Makefile of a base repository. Run `make help` in the terminal to see the full list of supported commands.

> NOTE Modify the [Makefile](Makefile) to meet the requirements of a base repository.

### 2.1. Git Hooks

  Triggers custom scripts in `/githooks` when certain Git actions occur.

### 2.2. Continuous Pipelines

- In Azure the pipelines in `/.azure` need to be added in Azure Pipelines service.
- In GitHub the `/.github/workflows` is a automated process that will run as configured on Pull Request (PR).

### 2.3. Code Analysis

See the [options](cmd/app/README.md) description for more information.

- Static Application Security Testing (SAST)

  Perform analysis of local staged files:

  ```bash
  make run-linter-staged
  ```

  Perform analysis of local modified files:

  ```bash
  make run-linter-diff
  ```

  Perform analysis of modified files in continuous integration pipeline:

  ```bash
  make run-linter-ci
  ```

- Dynamic Application Security Testing (DAST)

  Perform analysis of the application binary file:

  ```bash
  make run-sanitizer-app
  ```

- Software Composition Analysis (SCA)

  Perform security analysis of local project:

  ```bash
  make run-security-scan
  ```
