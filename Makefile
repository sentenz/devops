# See https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Display help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help

setup: ## Setup dependencies and tools
	cd scripts && chmod +x setup.sh && ./setup.sh
.PHONY: setup

setup-devops: ## Setup dependencies and tools for the devops service
	cd scripts && chmod +x setup_devops.sh && ./setup_devops.sh
.PHONY: setup-devops

cleanup-devops: ## Cleanup dependencies and tools of the devops service
	# TODO(AK)
.PHONY: setup-devops

setup-integration: ## Setup dependencies and tools for the integration service
	cd scripts/pipeline && chmod +x setup_continuous_integration.sh && ./setup_continuous_integration.sh
.PHONY: setup-integration

run-validate-staged: ## Perform validation of local staged files
	cd cmd && chmod +x validate.sh && ./validate.sh -l staged
.PHONY: run-validate-staged

run-validate-diff: ## Perform validation of local modified files
	cd cmd && chmod +x validate.sh && ./validate.sh -l diff
.PHONY: run-validate-diff

run-validate-ci: ## Perform validation of modified files in continuous integration pipeline
	cd cmd && chmod +x validate.sh && ./validate.sh -l ci
.PHONY: run-validate-ci

run-validate-commit: ## Perform validation of modified files in continuous integration pipeline
	commitlint --edit .git/COMMIT_EDITMSG
.PHONY: run-validate-commit

setup-testing: ## Setup dependencies and tools for the testing service
	cd scripts/pipeline && chmod +x setup_continuous_testing.sh && ./setup_continuous_testing.sh
.PHONY: setup-testing

setup-release: ## Setup dependencies and tools for the release service
	cd scripts/pipeline && chmod +x setup_continuous_release.sh && ./setup_continuous_release.sh
.PHONY: setup-release

run-release: ## Perform release service task
	npx semantic-release
.PHONY: run-release

setup-devcontainer: ## Setup dependencies and tools for the vscode devcontainer
	$(MAKE) setup
	$(MAKE) setup-devops
.PHONY: setup-devcontainer

setup-continuous-integration: ## Setup dependencies and tools for the continuous integration pipeline
	$(MAKE) setup-integration
.PHONY: setup-continuous-integration

run-continuous-integration: ## Perform task in continuous integration pipeline
	$(MAKE) run-validate-ci
.PHONY: run-continuous-integration

setup-continuous-testing: ## Setup dependencies and tools for the continuous testing pipeline
	$(MAKE) setup-testing
.PHONY: setup-continuous-testing

run-continuous-testing: ## Perform task in continuous testing pipeline
	# TODO(AK)
.PHONY: run-continuous-testing

setup-continuous-release: ## Setup dependencies and tools for the continuous release pipeline
	$(MAKE) setup-release
.PHONY: setup-continuous-release

run-continuous-release: ## Perform task in continuous release pipeline
	$(MAKE) run-release
.PHONY: run-continuous-release
