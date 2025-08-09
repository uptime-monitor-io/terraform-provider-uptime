# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Essential Commands
```bash
# Build the provider
make build

# Install locally for testing (creates ~/.terraformrc override)
make install

# Run unit tests with coverage
make test

# Run acceptance tests (requires API credentials)
TF_ACC=1 make testacc

# Run all validation checks (format, lint, test, security)
make validate

# Generate documentation
make docs

# Build for all platforms
make dist

# Clean build artifacts
make clean
```

### Testing Commands
```bash
# Run specific test
go test ./internal/provider -run TestMonitorResource

# Run tests with verbose output
go test -v ./...

# Run tests with race detection
go test -race ./...

# Run acceptance tests for specific resource
TF_ACC=1 go test ./internal/provider -run TestAccMonitorResource -v
```

### Development Workflow
```bash
# Before committing, run full validation
./scripts/validate.sh

# Format code
go fmt ./...

# Run linter
golangci-lint run

# Security scan
gosec -quiet ./...
```

## Architecture Overview

This is a Terraform provider for UptimeMonitor.io built with the modern Terraform Plugin Framework (not the legacy SDK). The provider enables management of monitors, contacts, and status pages through Terraform.

### Core Components

**Provider Entry Point**: `main.go` serves the provider via gRPC to Terraform.

**API Client** (`internal/client/`): HTTP client handling authentication and communication with UptimeMonitor.io API. Uses Bearer token authentication with proper error handling and retry logic.

**Provider Configuration** (`internal/provider/provider.go`): Main provider implementation that:
- Registers all resources and data sources
- Handles provider configuration (API key, base URL)
- Creates and configures the API client

**Resources** (`internal/resources/`):
- `monitor_resource.go`: HTTPS/TCP/Ping monitor management with full CRUD operations
- `contact_resource.go`: Contact management for notifications
- `status_page_resource.go`: Public status page configuration

**Data Sources** (`internal/datasources/`):
- Read-only access to existing resources
- Account information retrieval

### Key Design Patterns

1. **Schema-Driven**: All resources use declarative schemas with proper validation
2. **State Management**: Terraform state properly synchronized with API
3. **Error Handling**: Comprehensive error handling with diagnostic messages
4. **Attribute Types**: Uses framework types (types.String, types.Int64) for null safety
5. **Import Support**: Resources support importing existing infrastructure

### Testing Strategy

**Unit Tests**: Test schema validation, resource metadata, and client logic in isolation.

**Acceptance Tests**: Full integration tests that:
- Create real resources in UptimeMonitor.io
- Verify state management
- Test update and delete operations
- Require environment variables: `UPTIME_API_KEY`

### Development Notes

- The provider uses the modern Plugin Framework, not the legacy SDK - use framework-specific patterns
- All resources must implement Create, Read, Update, Delete, and ImportState methods
- Use `resp.Diagnostics` for error reporting, not Go errors directly
- Monitor resources support multiple types (HTTPS, TCP, Ping) with type-specific validation
- Contact associations use monitor IDs, not contact IDs (API quirk)
- Status pages link to monitors via monitor IDs

### Common Patterns

**Resource CRUD Operations**:
```go
func (r *MonitorResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse)
func (r *MonitorResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse)
func (r *MonitorResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse)
func (r *MonitorResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse)
```

**State Management**:
```go
// Read from plan/state
var data MonitorResourceModel
resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

// Write to state
resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
```

**API Client Usage**:
```go
monitor, err := r.client.CreateMonitor(ctx, monitorReq)
if err != nil {
    resp.Diagnostics.AddError("API Error", err.Error())
    return
}
```

## Development Best Practices

### Git Workflow
- Work in branches, create PRs, commit often
- Run tests before committing
- Update PR summary after pushing additional commits to PR