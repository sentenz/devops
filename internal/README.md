# `/internal`

Scripts to perform various install, analysis, test, build or release operations.

- [1. Git](#1-git)
  - [1.1. Hooks](#11-hooks)
  - [1.2. Requirements](#12-requirements)
  - [1.3. Install](#13-install)
  - [1.4. Usage](#14-usage)
- [2. Node.js](#2-nodejs)
  - [2.1. Requirements](#21-requirements)
  - [2.2. Install](#22-install)
  - [2.3. Usage](#23-usage)
  - [2.4. Configuration](#24-configuration)
- [3. Directories](#3-directories)
  - [3.1. `/app`](#31-app)
  - [3.2. `/lint`](#32-lint)

## 1. Git

[Git](https://git-scm.com/)

### 1.1. Hooks

[githooks](https://git-scm.com/docs/githooks)

### 1.2. Requirements

`apt` package management system for installing, upgrading, configuring, and removing software.

### 1.3. Install

```bash
sudo apt install -y git
```

### 1.4. Usage

```bash
git init
```


## 2. Node.js

### 2.1. Requirements

`apt` package management system for installing, upgrading, configuring, and removing software.

### 2.2. Install

Installing Node.js via package manager. Debian and Ubuntu based Linux distributions are available from [Node.js binary distributions](https://github.com/nodesource/distributions/blob/master/README.md).

[Node.js v12.x](https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions):

```bash
# Using Ubuntu
sudo apt install -y nodejs
```

### 2.3. Usage

Install `npm`, the Node.js package manager.

```bash
sudo apt install -y npm
```

### 2.4. Configuration

[Configuring npm](https://docs.npmjs.com/cli/v6/configuring-npm).

Creating a `package.json` file:

```bash
npm init
```

A package.json file:

- lists the packages your project depends on
- specifies versions of a package that your project can use using semantic versioning rules
- makes your build reproducible, and therefore easier to share with other developers

[Installs a package](https://docs.npmjs.com/cli/v6/commands/npm-install), and any packages that it depends on.

```bash
npm install
```

## 3. Directories

### 3.1. `/app`

### 3.2. `/lint`

Linting scripts to `validate` the code base via CLI.

- [x] [remark-lint](https://github.com/remarkjs/remark-lint)
- [x] golangci-lint
- [x] clang-tidy
- [x] cpplint
- [x] shellcheck
- [x] markdownlint
- [x] commitlint
- [x] jsonlint
- [ ] [ineffassign](https://github.com/gordonklaus/ineffassign)
- [ ] [errcheck](https://github.com/kisielk/errcheck)
- [ ] [misspell](https://github.com/client9/misspell)
- [ ] [gocyclo](https://github.com/fzipp/gocyclo)
- [ ] clang-analyzer (scan-build)
- [x] valgrind
- [x] staticcheck
- [x] cppcheck
- [x] markdown-link-check
- [x] markdown-spell-check
- [x] alex
- [x] codespell
- [x] gofmt
- [x] clang-format
- [x] shfmt
- [x] [markdown-table-formatter](https://github.com/nvuillam/markdown-table-formatter)
- [ ] [licensing](https://code.tools/man/1/licensing)
- [ ] [golicense](https://github.com/mitchellh/golicense)
- [x] licensecheck
- [x] semantic-release
