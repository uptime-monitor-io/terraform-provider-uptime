#!/usr/bin/env bash

# Terraform Provider Validation Script
# This script runs all checks that would run in CI to catch issues before pushing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Track if any step fails
FAILED=0

# Function to run a command and check result
run_check() {
    local name=$1
    shift
    print_step "Running $name..."
    if "$@"; then
        print_success "$name passed"
    else
        print_error "$name failed"
        FAILED=1
        return 1
    fi
}

# Main validation steps
echo "🔍 Starting Terraform Provider Validation"
echo "========================================="
echo ""

# 1. Check Go formatting
print_step "Checking Go formatting..."
if ! gofmt -l . | grep -q .; then
    print_success "Go formatting is correct"
else
    print_error "Go formatting issues found. Run 'go fmt ./...' to fix"
    gofmt -l .
    FAILED=1
fi

# 2. Run go mod tidy and check for changes
print_step "Checking go.mod and go.sum..."
cp go.mod go.mod.backup
cp go.sum go.sum.backup
go mod tidy
if diff go.mod go.mod.backup > /dev/null && diff go.sum go.sum.backup > /dev/null; then
    print_success "go.mod and go.sum are tidy"
else
    print_error "go.mod or go.sum needs updating. Run 'go mod tidy'"
    FAILED=1
fi
rm go.mod.backup go.sum.backup

# 3. Run go vet
run_check "go vet" go vet ./...

# 4. Run golangci-lint if available
if command -v golangci-lint &> /dev/null; then
    run_check "golangci-lint" golangci-lint run --timeout=5m
else
    print_warning "golangci-lint not installed. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
fi

# 5. Run tests
print_step "Running unit tests..."
if go test -race -coverprofile=coverage.txt -covermode=atomic ./...; then
    print_success "All tests passed"
    
    # Show coverage summary
    print_step "Test coverage summary:"
    go tool cover -func=coverage.txt | tail -1
    rm coverage.txt
else
    print_error "Tests failed"
    FAILED=1
fi

# 6. Build the provider
run_check "build" go build -o terraform-provider-uptime

# 7. Check for security issues with gosec if available
if command -v gosec &> /dev/null; then
    run_check "security scan" gosec -quiet ./...
else
    print_warning "gosec not installed. Install with: go install github.com/securego/gosec/v2/cmd/gosec@latest"
fi

# 8. Check documentation with tfplugindocs if available
if command -v tfplugindocs &> /dev/null; then
    print_step "Checking provider documentation..."
    tfplugindocs generate --provider-name uptime --rendered-provider-name "Uptime Monitor"
    if git diff --exit-code docs/; then
        print_success "Documentation is up to date"
    else
        print_error "Documentation needs updating. Run 'make docs'"
        git checkout -- docs/
        FAILED=1
    fi
else
    print_warning "tfplugindocs not installed. Install with: go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs@latest"
fi

# 9. Run acceptance tests if requested
if [ "$1" == "--acceptance" ] || [ "$1" == "-a" ]; then
    if [ -z "$UPTIME_API_KEY" ] || [ -z "$UPTIME_BASE_URL" ]; then
        print_warning "Skipping acceptance tests: UPTIME_API_KEY or UPTIME_BASE_URL not set"
    else
        print_step "Running acceptance tests..."
        if TF_ACC=1 go test -v -timeout 30m ./... -run ^TestAcc; then
            print_success "Acceptance tests passed"
        else
            print_error "Acceptance tests failed"
            FAILED=1
        fi
    fi
fi

# 10. Check for uncommitted changes
print_step "Checking for uncommitted changes..."
if git diff --exit-code > /dev/null && git diff --cached --exit-code > /dev/null; then
    print_success "No uncommitted changes"
else
    print_warning "You have uncommitted changes"
    git status --short
fi

# Summary
echo ""
echo "========================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All validation checks passed!${NC}"
    echo "Your code is ready to push."
    
    # Clean up build artifact
    rm -f terraform-provider-uptime
    exit 0
else
    echo -e "${RED}❌ Validation failed!${NC}"
    echo "Please fix the issues above before pushing."
    
    # Clean up build artifact
    rm -f terraform-provider-uptime
    exit 1
fi