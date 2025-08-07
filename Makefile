# Terraform Provider for Uptime Monitor
# Terraform provider for uptime monitoring service

VERSION ?= dev
BINARY = terraform-provider-uptime
PLATFORMS = linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64
COVERAGE_FILE = coverage.txt

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  ${BLUE}%-15s${NC} %s\n", $$1, $$2 } /^##@/ { printf "\n${YELLOW}%s${NC}\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: build
build: ## Build the provider binary
	go build -o $(BINARY) .

.PHONY: install
install: build ## Install provider locally for testing
	@OS=$$(go env GOOS); \
	ARCH=$$(go env GOARCH); \
	mkdir -p ~/.terraform.d/plugins/localhost/uptime/uptime/$(VERSION)/$${OS}_$${ARCH}/; \
	cp $(BINARY) ~/.terraform.d/plugins/localhost/uptime/uptime/$(VERSION)/$${OS}_$${ARCH}/
	@echo "${GREEN}✓${NC} Provider installed to ~/.terraform.d/plugins/"

.PHONY: dev
dev: fmt lint test build ## Run all development checks

##@ Testing

.PHONY: test
test: ## Run unit tests
	go test -v -race -coverprofile=$(COVERAGE_FILE) -covermode=atomic ./...

.PHONY: test-short
test-short: ## Run unit tests (short mode)
	go test -short ./...

.PHONY: test-coverage
test-coverage: test ## Run tests and show coverage report
	@go tool cover -func=$(COVERAGE_FILE)
	@go tool cover -html=$(COVERAGE_FILE) -o coverage.html
	@echo "${GREEN}✓${NC} Coverage report generated: coverage.html"

.PHONY: testacc
testacc: ## Run acceptance tests (requires UPTIME_API_KEY and UPTIME_BASE_URL)
	TF_ACC=1 go test -v -timeout 120m ./... -run ^TestAcc

##@ Code Quality

.PHONY: fmt
fmt: ## Format Go code
	go fmt ./...
	@echo "${GREEN}✓${NC} Code formatted"

.PHONY: fmt-check
fmt-check: ## Check if code is formatted
	@if [ -n "$$(gofmt -l .)" ]; then \
		echo "${RED}✗${NC} Code needs formatting. Run 'make fmt'"; \
		gofmt -l .; \
		exit 1; \
	else \
		echo "${GREEN}✓${NC} Code is properly formatted"; \
	fi

.PHONY: vet
vet: ## Run go vet
	go vet ./...
	@echo "${GREEN}✓${NC} No vet issues found"

.PHONY: lint
lint: ## Run golangci-lint
	@if command -v golangci-lint &> /dev/null; then \
		golangci-lint run --timeout=5m; \
		echo "${GREEN}✓${NC} Linting passed"; \
	else \
		echo "${YELLOW}⚠${NC} golangci-lint not installed. Install with:"; \
		echo "  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

.PHONY: security
security: ## Run security scan with gosec
	@if command -v gosec &> /dev/null; then \
		gosec -quiet ./...; \
		echo "${GREEN}✓${NC} Security scan passed"; \
	else \
		echo "${YELLOW}⚠${NC} gosec not installed. Install with:"; \
		echo "  go install github.com/securego/gosec/v2/cmd/gosec@latest"; \
	fi

.PHONY: mod-tidy
mod-tidy: ## Run go mod tidy
	go mod tidy
	@echo "${GREEN}✓${NC} go.mod and go.sum are tidy"

.PHONY: validate
validate: ## Run all validation checks (what runs before push)
	@./scripts/validate.sh

.PHONY: validate-all
validate-all: ## Run all validation checks including acceptance tests
	@./scripts/validate.sh --acceptance

##@ Documentation

.PHONY: docs
docs: ## Generate provider documentation
	@if command -v tfplugindocs &> /dev/null; then \
		tfplugindocs generate --provider-name uptime --rendered-provider-name "Uptime Monitor"; \
		echo "${GREEN}✓${NC} Documentation generated"; \
	else \
		echo "${YELLOW}⚠${NC} tfplugindocs not installed. Install with:"; \
		echo "  go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs@latest"; \
	fi

.PHONY: docs-check
docs-check: ## Check if documentation is up to date
	@if command -v tfplugindocs &> /dev/null; then \
		tfplugindocs generate --provider-name uptime --rendered-provider-name "Uptime Monitor"; \
		if git diff --exit-code docs/; then \
			echo "${GREEN}✓${NC} Documentation is up to date"; \
		else \
			echo "${RED}✗${NC} Documentation needs updating. Run 'make docs'"; \
			git checkout -- docs/; \
			exit 1; \
		fi \
	else \
		echo "${YELLOW}⚠${NC} tfplugindocs not installed"; \
	fi

##@ Build & Distribution

.PHONY: clean
clean: ## Clean build artifacts
	rm -f $(BINARY)
	rm -rf dist/
	rm -f $(COVERAGE_FILE) coverage.html
	@echo "${GREEN}✓${NC} Cleaned build artifacts"

.PHONY: dist
dist: clean ## Build for all platforms
	mkdir -p dist
	@for platform in $(PLATFORMS); do \
		GOOS=$$(echo $$platform | cut -d'/' -f1); \
		GOARCH=$$(echo $$platform | cut -d'/' -f2); \
		echo "Building for $$GOOS/$$GOARCH..."; \
		GOOS=$$GOOS GOARCH=$$GOARCH go build -o dist/$(BINARY)_$(VERSION)_$${GOOS}_$${GOARCH} .; \
	done
	@echo "${GREEN}✓${NC} Built for all platforms"

##@ Dependencies

.PHONY: deps
deps: ## Download dependencies
	go mod download
	@echo "${GREEN}✓${NC} Dependencies downloaded"

.PHONY: deps-upgrade
deps-upgrade: ## Upgrade all dependencies to latest versions
	go get -u ./...
	go mod tidy
	@echo "${GREEN}✓${NC} Dependencies upgraded"

.PHONY: tools
tools: ## Install development tools
	@echo "Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/securego/gosec/v2/cmd/gosec@latest
	go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs@latest
	@echo "${GREEN}✓${NC} Development tools installed"

##@ Composite Targets

.PHONY: all
all: fmt lint test build ## Run fmt, lint, test, and build

.PHONY: ci
ci: fmt-check vet lint test build ## Run all CI checks

.PHONY: pre-push
pre-push: validate ## Run pre-push validation

.DEFAULT_GOAL := help