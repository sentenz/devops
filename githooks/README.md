# `/githooks`

Git hooks provides the ability to trigger custom scripts when certain actions occur.

- [Hooks](#hooks)
  - [pre-commit](#pre-commit)
  - [commit-msg](#commit-msg)
  - [pre-push](#pre-push)
- [Configuration](#configuration)

## Hooks

### pre-commit

The pre-commit hook is run first, before you even type in a commit message. It’s used to inspect the snapshot that’s about to be committed, to see if you’ve forgotten something, to make sure tests run, or to examine whatever you need to inspect in the code.
You can run linter to check the staged files.

Contained actions for linters:

- [pre-commit](https://pre-commit.com/)
  > The .pre-commit-config.yaml file is required to install the configured linter.

### commit-msg

The commit-msg hook takes one parameter, which is the path to a temporary file that contains the commit message written by the developer. If this script exits non-zero, Git aborts the commit process.

Contained actions:

### pre-push

The pre-push hook runs during git push, after the remote refs have been updated but before any objects have been transferred. It receives the name and location of the remote as parameters, and a list of to-be-updated refs through stdin. You can use it to validate a set of ref updates before a push occurs. In this case the pre-push hook prevents pushing into branch.

Contained actions for branching strategy:

- prevent pushes to main branches
- enforce naming convention for support branches

## Configuration

The .git folder is not under version control, since most of its contents are device and user-specific. If you’re using Git version 2.9 or greater, change the hooks directory using core.hooksPath configuration variable. Create a folder inside the repository and place it under version control and change the hooks directory with the following command:

```bash
git config core.hooksPath path/to/githooks-folder
```

An alternative for git version under 2.9 is to create a symbolic link between the hooks located in .git and this folder.

Make sure your hooks are executable, if not use the following command:

```bash
chmod +x path/to/hook-file
```
