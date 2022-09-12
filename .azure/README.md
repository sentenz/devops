# `/.azure`

- continuous-security.yml
  > An yaml file containing actions for continuous security pipeline, triggered by pull request (PR) events.
  >
  > NOTE PR triggers are configured in [Azure Repos Git](https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops&tabs=browser#build-validation) using branch policies.
  > E.g. Repos > Branches > main > Branch Policies > Build Validation

- continuous-integration.yml
  > An yaml file containing actions for continuous integration pipeline, triggered upon the completion of another pipeline.

- continuous-testing.yml
  > An yaml file containing actions for continuous testing pipeline, triggered upon the completion of another pipeline.

- continuous-release.yml
  > An yaml file containing actions for continuous release pipeline, triggered from base branch.
