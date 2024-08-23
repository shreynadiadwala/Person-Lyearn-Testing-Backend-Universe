MODULES := $(shell find . -name go.mod -exec dirname {} \;)
PACKAGES := $(shell find ./packages -name go.mod -exec dirname {} \;)
SERVICES := $(shell find ./services -name go.mod -exec dirname {} \;)
CONSUMERS := $(shell find ./consumers -name go.mod -exec dirname {} \;)

.PHONY: set-precommit-hooks
set-precommit-hooks:
	chmod ug+x .githooks/pre-commit && command -v git >/dev/null && git config core.hooksPath .githooks || true

.PHONY: setup-workspace
setup-workspace:
	go work init; \
	for module in $(MODULES); do \
		echo "Setting up workspace for $$module"; \
		go work use $$module; \
	done

define clean_target
	for module in $(1); do \
		echo "Cleaning dependencies for $$module"; \
		cd $$module; \
		go mod tidy; \
		cd - > /dev/null; \
	done
endef

.PHONY: clean-all-deps
clean-all-deps:
	@$(call clean_target,$(MODULES))

define force_clean_target
	go clean -cache && go clean -modcache; \
	for module in $(1); do \
		echo "Cleaning dependencies for $$module"; \
		cd $$module; \
		go mod tidy; \
		cd - > /dev/null; \
	done
endef

.PHONY: force-clean-all-deps
force-clean-all-deps: 
	@$(call force_clean_target,$(MODULES))

define update_target
	for module in $(1); do \
		echo "Fetching dependencies for $$module"; \
		cd $$module; \
		echo "Running: go get ./..."; \
		go get ./...; \
		deps=$$(grep -oP '^github\\.com/Lyearn[^\s]*' go.mod); \
		for dep in $$deps; do \
			echo "Running: go get $$dep@latest"; \
			go get $$dep@latest; \
		done; \
		echo "Running: go mod tidy"; \
		go mod tidy; \
		cd - > /dev/null; \
	done
endef


.PHONY: update-all-deps
update-all-deps: 
	@$(call update_target,$(MODULES))

.PHONY: update-service-deps
update-service-deps: 
	@if [ -z "$(services)" ]; then \
		echo "Services string required. Use: make build-services services='svc1 svc2'"; \
		exit 1; \
	fi
	go clean -cache && go clean -modcache; \
	SERVICES=$$(echo $(services) | tr ' ' '\n' | sed 's/^/.\/services\//'); \
	$(call update_target,$$SERVICES)

.PHONY: update-consumer-deps
update-consumer-deps: 
	@if [ -z "$(consumers)" ]; then \
		echo "Consumers string required. Use: make build-consumers consumers='consumer1 consumer2'"; \
		exit 1; \
	fi
	go clean -cache && go clean -modcache; \
	CONSUMERS=$$(echo $(consumers) | tr ' ' '\n' | sed 's/^/.\/consumers\//'); \
	$(call update_target,$$CONSUMERS)

define build_target
	for module in $(1); do \
		echo "Building $$module"; \
		cd $$module; \
		go build -v $(GO_LD_FLAGS) ./... || exit 1 ; \
		cd - > /dev/null; \
	done
endef

.PHONY: build-all
build-all: 
	@$(call build_target,$(MODULES))

.PHONY: build-all-packages
build-all-packages: 
	@$(call build_target,$(PACKAGES))

.PHONY: build-all-services
build-all-services: 
	@$(call build_target,$(SERVICES))

.PHONY: build-all-consumers
build-all-consumers: 
	@$(call build_target,$(CONSUMERS))

.PHONY: replace-deps
replace-deps: 
	@if [ -z "$(module)" ]; then \
		echo "Module path required. Use: make replace-deps module=<module-path>"; \
		exit 1; \
	fi
	@cd $(module); \
	awk '/require \(/,/)/' go.mod | grep 'github.com/Lyearn/backend-universe/packages' | while read -r line; do \
		PACKAGE=$$(echo $$line | awk '{print $$1}'); \
		go get $$PACKAGE@latest; \
	done; \
	go mod tidy
