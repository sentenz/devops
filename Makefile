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

cleanup-devops: ## Cleanup dependencies and tools for the devops service
	# TODO(AK)
.PHONY: setup-devops

setup-devcontainer: ## Setup dependencies and tools for the vscode devcontainer
	$(MAKE) setup
	$(MAKE) setup-devops
.PHONY: setup-devcontainer

setup-continuous-integration: ## Setup dependencies and tools for the continuous integration pipeline
	$(MAKE) setup-integration
.PHONY: setup-continuous-integration

run-continuous-integration: ## Perform task in continuous integration pipeline
	$(MAKE) run-lint-ci
.PHONY: run-continuous-integration

setup-continuous-release: ## Setup dependencies and tools for the continuous release pipeline
	$(MAKE) setup-release
.PHONY: setup-continuous-release

run-continuous-release: ## Perform task in continuous release pipeline
	$(MAKE) run-release
.PHONY: run-continuous-release

run-githooks-pre-commit: ## Perform task in githooks pre-commit event
	$(MAKE) run-lint-staged
.PHONY: run-githooks-pre-commit

run-lint-staged: ## Perform linting local staged files
	cd cmd && chmod +x validate.sh && ./validate.sh -l staged
.PHONY: run-lint-staged

run-lint-diff: ## Perform linting local changed files
	cd cmd && chmod +x validate.sh && ./validate.sh -l diff
.PHONY: run-lint-diff

run-lint-ci: ## Perform linting changed files in continuous integration pipeline
	cd cmd && chmod +x validate.sh && ./validate.sh -l ci
.PHONY: run-lint-ci

setup-integration: ## Setup dependencies and tools for the integration service
	cd scripts/pipeline && chmod +x continuous_integration.sh && ./continuous_integration.sh
.PHONY: setup-integration

setup-release: ## Setup dependencies and tools for the release service
	cd scripts/pipeline && chmod +x continuous_release.sh && ./continuous_release.sh
.PHONY: setup-release

run-release: ## Perform release service task
	npx semantic-release
.PHONY: run-release
