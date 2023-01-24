ifneq (,$(wildcard ./.env))
	include .env
	export
endif

URL_DEVOPS := https://github.com/sentenz/devops.git
PATH_DEVOPS := .
PATH_BINARY_APP := ./test/bin/passes-binary
PATH_BINARY_TEST := ./test/bin/fails-binary

# See https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Display help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help

setup: ## Setup dependencies and tools
	cd $(@D)/scripts && chmod +x setup.sh && ./setup.sh
.PHONY: setup

setup-devops: ## Setup dependencies and tools for the devops service
	cd $(PATH_DEVOPS)/scripts && chmod +x setup.sh && ./setup.sh
.PHONY: setup-devops

setup-devcontainer: ## Setup dependencies and tools for the vscode devcontainer
	$(MAKE) update-submodule
	$(MAKE) setup
.PHONY: setup-devcontainer

setup-security: ## Setup dependencies and tools for the security service
	cd $(@D)/scripts/pipeline && chmod +x setup_security.sh && ./setup_security.sh
.PHONY: setup-security

setup-integration: ## Setup dependencies and tools for the integration service
	cd $(@D)/scripts/pipeline && chmod +x setup_integration.sh && ./setup_integration.sh
.PHONY: setup-integration

setup-build: ## Setup dependencies and tools for the build service
	# TODO(AK)
	# cd $(@D)/scripts/pipeline && chmod +x setup_build.sh && ./setup_build.sh
.PHONY: setup-build

setup-testing: ## Setup dependencies and tools for the testing service
	cd $(@D)/scripts/pipeline && chmod +x setup_testing.sh && ./setup_testing.sh
.PHONY: setup-testing

setup-release: ## Setup dependencies and tools for the release service
	cd $(@D)/scripts/pipeline && chmod +x setup_release.sh && ./setup_release.sh
.PHONY: setup-release

setup-continuous-integration: ## Setup dependencies and tools for the continuous integration pipeline
	$(MAKE) update-submodule
	$(MAKE) setup-integration
.PHONY: setup-continuous-integration

setup-continuous-build: ## Setup dependencies and tools for the continuous build pipeline
	$(MAKE) setup-build
.PHONY: setup-continuous-build

setup-continuous-testing: ## Setup dependencies and tools for the continuous testing pipeline
	$(MAKE) setup-testing
.PHONY: setup-continuous-testing

setup-continuous-release: ## Setup dependencies and tools for the continuous release pipeline
	$(MAKE) setup-release
.PHONY: setup-continuous-release

teardown-devops: ## Teardown dependencies and tools for the devops service
	cd $(PATH_DEVOPS)/scripts && chmod +x teardown.sh && ./teardown.sh
.PHONY: teardown-devops

update-devops: ## Update dependencies and tools for the devops service
	$(MAKE) teardown-devops
	$(MAKE) update-submodule
	$(MAKE) setup-devops
.PHONY: update-devops

run-linter-staged: ## Perform analysis of local staged files
	cd $(PATH_DEVOPS)/cmd/app && chmod +x sast.sh && ./sast.sh -l staged
.PHONY: run-linter-staged

run-linter-diff: ## Perform analysis of local modified files
	cd $(PATH_DEVOPS)/cmd/app && chmod +x sast.sh && ./sast.sh -l diff
.PHONY: run-linter-diff

run-linter-ci: ## Perform analysis of modified files in continuous integration pipeline
	cd $(PATH_DEVOPS)/cmd/app && chmod +x sast.sh && ./sast.sh -l ci
.PHONY: run-linter-ci

run-linter-commit: ## Perform analysis of the commit message
	commitlint --edit .git/COMMIT_EDITMSG
.PHONY: run-linter-commit

run-sanitizer-app: ## Perform analysis of the application binary file
	cd $(PATH_DEVOPS)/cmd/app && chmod +x dast.sh && ./dast.sh -b $(PATH_BINARY_APP)
.PHONY: run-sanitizer-app

run-sanitizer-test: ## Perform analysis of the test binary file
	cd $(PATH_DEVOPS)/cmd/app && chmod +x dast.sh && ./dast.sh -b $(PATH_BINARY_TEST)
.PHONY: run-sanitizer-test

run-release: ## Perform release service task
	npx semantic-release
.PHONY: run-release

run-continuous-integration: ## Perform task in continuous integration pipeline
	$(MAKE) run-linter-ci
.PHONY: run-continuous-integration

run-continuous-build: ## Perform task in continuous build pipeline
	# TODO(AK)
.PHONY: run-continuous-build

run-continuous-testing: ## Perform task in continuous testing pipeline
	# TODO(AK)
.PHONY: run-continuous-testing

run-continuous-release: ## Perform task in continuous release pipeline
	$(MAKE) run-release
.PHONY: run-continuous-release

setup-submodule-devops: ## Setup git submodule devops service
	git submodule add $(URL_DEVOPS) $(PATH_DEVOPS)
.PHONY: setup-submodule-devops

setup-submodule: ## Setup git submodules
	$(MAKE) setup-submodule-devops
.PHONY: setup-submodule

update-submodule: ## Update git submodules
	git submodule update --remote --recursive --merge --init
.PHONY: update-submodule

teardown-submodule: ## Remove git submodules
	# TODO(AK)
.PHONY: teardown-submodule

install-extensions: ## Install recommended VS Code extensions
	code --list-extensions | xargs -L 1 code --install-extension
.PHONY: install-extensions
