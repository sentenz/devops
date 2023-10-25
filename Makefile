ifneq (,$(wildcard .env))
	include .env
	export
endif

# See https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Display help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help

setup: ## Setup dependencies and tools
	cd $(@D)/scripts && chmod +x setup.sh && ./setup.sh
.PHONY: setup

setup-devcontainer: ## Setup dependencies and tools for the vscode devcontainer
	$(MAKE) submodule-update
	$(MAKE) setup
.PHONY: setup-devcontainer

setup-security: ## Setup dependencies and tools for the security service
	cd $(@D)/scripts/pipeline && chmod +x setup_security.sh && ./setup_security.sh
.PHONY: setup-security

setup-integration: ## Setup dependencies and tools for the integration service
	cd $(@D)/scripts/pipeline && chmod +x setup_integration.sh && ./setup_integration.sh
.PHONY: setup-integration

setup-build: ## Setup dependencies and tools for the build service
	cd $(@D)/scripts/pipeline && chmod +x setup_build.sh && ./setup_build.sh
.PHONY: setup-build

setup-testing: ## Setup dependencies and tools for the testing service
	cd $(@D)/scripts/pipeline && chmod +x setup_testing.sh && ./setup_testing.sh
.PHONY: setup-testing

setup-release: ## Setup dependencies and tools for the release service
	cd $(@D)/scripts/pipeline && chmod +x setup_release.sh && ./setup_release.sh
.PHONY: setup-release

setup-continuous-security: ## Setup dependencies and tools for the continuous security pipeline
	$(MAKE) submodule-update
	$(MAKE) setup-security
.PHONY: setup-continuous-security

setup-continuous-integration: ## Setup dependencies and tools for the continuous integration pipeline
	$(MAKE) submodule-update
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

run-continuous-security: ## Perform task in continuous security pipeline
	$(MAKE) run-security-scan
.PHONY: run-continuous-security

run-continuous-integration: ## Perform task in continuous integration pipeline
	$(MAKE) run-linter-ci
.PHONY: run-continuous-integration

run-continuous-build: ## Perform task in continuous build pipeline
	$(MAKE) app-build
	$(MAKE) app-run
.PHONY: run-continuous-build

run-continuous-testing: ## Perform task in continuous testing pipeline
	$(MAKE) test-unit
	$(MAKE) test-cover
.PHONY: run-continuous-testing

run-continuous-release: ## Perform task in continuous release pipeline
	$(MAKE) run-release
.PHONY: run-continuous-release

devops-setup: ## Setup dependencies and tools for the devops service
	cd $(DEVOPS_PATH)/scripts && chmod +x setup.sh && ./setup.sh
.PHONY: devops-setup

devops-teardown: ## Teardown dependencies and tools for the devops service
	cd $(DEVOPS_PATH)/scripts && chmod +x teardown.sh && ./teardown.sh
.PHONY: devops-teardown

devops-update: ## Update dependencies and tools for the devops service
	$(MAKE) devops-teardown
	$(MAKE) submodule-update
	$(MAKE) devops-setup
.PHONY: devops-update

install-linters: ## Install linters for static code analysis
	ansible-playbook $(@D)/configs/playbook/install-linters.yml
.PHONY: install-linters

uninstall-linters: ## Uninstall linters for static code analysis
	ansible-playbook $(@D)/configs/playbook/uninstall-linters.yml
.PHONY: install-linters

run-linter-staged: ## Perform analysis of local staged files
	cd $(DEVOPS_PATH)/cmd/app && chmod +x sast.sh && ./sast.sh -l staged
.PHONY: run-linter-staged

run-linter-diff: ## Perform analysis of local modified files
	cd $(DEVOPS_PATH)/cmd/app && chmod +x sast.sh && ./sast.sh -l diff
.PHONY: run-linter-diff

run-linter-ci: ## Perform analysis of modified files in continuous integration pipeline
	cd $(DEVOPS_PATH)/cmd/app && chmod +x sast.sh && ./sast.sh -l ci
.PHONY: run-linter-ci

run-linter-commit: ## Perform analysis of the commit message
	commitlint --edit .git/COMMIT_EDITMSG
.PHONY: run-linter-commit

run-sanitizer-app: ## Perform analysis of the application binary file
	cd $(DEVOPS_PATH)/cmd/app && chmod +x dast.sh && ./dast.sh -b $(PATH_BINARY_APP)
.PHONY: run-sanitizer-app

run-sanitizer-test: ## Perform analysis of the test binary file
	cd $(DEVOPS_PATH)/cmd/app && chmod +x dast.sh && ./dast.sh -b $(PATH_BINARY_TEST)
.PHONY: run-sanitizer-test

run-security-scan: ## Perform security analysis of local project
	cd $(DEVOPS_PATH)/cmd/app && chmod +x sca.sh && ./sca.sh -p $(@D)
.PHONY: run-security-scan

run-release: ## Perform release service task
	npx semantic-release
.PHONY: run-release

submodule-setup-devops: ## Setup git submodule devops service
	git submodule add -f --name $(DEVOPS_NAME) $(DEVOPS_URL) $(DEVOPS_PATH)
.PHONY: submodule-setup-devops

submodule-teardown-devops: ## Teardown git submodule devops service
	git submodule deinit -f $(DEVOPS_PATH)
	rm -rf .git/modules/$(DEVOPS_NAME)
	git rm -rf $(DEVOPS_PATH)
.PHONY: submodule-teardown-devops

submodule-setup: ## Setup git submodules
	$(MAKE) submodule-setup-devops
.PHONY: submodule-setup

submodule-update: ## Update git submodules
	git submodule update --remote --recursive --merge --init
.PHONY: submodule-update

submodule-teardown: ## Remove git submodules
	$(MAKE) submodule-teardown-devops
.PHONY: submodule-teardown

app-build: ## Perform application build
	mkdir -p $(@D)/cmd/bin
	# TODO(AK)
.PHONY: app-build

app-run: ## Perform application run
	# TODO(AK)
.PHONY: app-run

app-audit: ## Perform application audit
	mkdir -p $(@D)/logs/audit
	# TODO(AK)
.PHONY: app-audit

test-unit: ## Perform unit test
	mkdir -p $(@D)/logs/test
	# TODO(AK)
.PHONY: app-test

test-fuzz: ## ## Perform fuzz test
	# TODO(AK)
.PHONY: test-fuzz

test-bench: ## Perform benchmark test
	mkdir -p $(@D)/logs/test
	# TODO(AK)
.PHONY: test-bench

test-cover: ## Perform code coverage
	mkdir -p $(@D)/logs/test
	# TODO(AK)
.PHONY: test-cover
