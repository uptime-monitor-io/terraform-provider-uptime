# Terraform Provider for Uptime Monitor

[![CI](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/actions/workflows/ci.yml/badge.svg)](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/actions/workflows/ci.yml)
[![Release](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/actions/workflows/release.yml/badge.svg)](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/actions/workflows/release.yml)
[![Documentation](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/actions/workflows/docs.yml/badge.svg)](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/actions/workflows/docs.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/codematters-llc/uptime-monitor-io-terraform-provider)](https://goreportcard.com/report/github.com/codematters-llc/uptime-monitor-io-terraform-provider)
[![License](https://img.shields.io/github/license/codematters-llc/uptime-monitor-io-terraform-provider)](https://github.com/codematters-llc/uptime-monitor-io-terraform-provider/blob/main/LICENSE)

A Terraform provider for managing uptime monitors through the Uptime Monitor API.

## Features

- **Monitor Management**: Create, update, and delete HTTP/HTTPS, TCP, and Ping monitors
- **Advanced HTTPS Configuration**: Support for custom headers, body validation, certificate checking, and status code expectations
- **Multi-region Support**: Deploy monitors across multiple geographic regions
- **Terraform Integration**: Full lifecycle management with proper state handling

## Installation

### Local Development

1. Build the provider:
```bash
make build
```

2. Install locally for Terraform:
```bash
make install
```

3. Configure Terraform to use the local provider:
```hcl
terraform {
  required_providers {
    uptime = {
      source  = "localhost/uptime/uptime"
      version = "dev"
    }
  }
}
```

### Production Distribution

Build binaries for all platforms:
```bash
make dist
```

Distribute the appropriate binary to your users along with installation instructions.

## Usage

### Provider Configuration

```hcl
provider "uptime" {
  api_key  = "your-api-key-here"
  base_url = "https://api.uptime-monitor.io"  # Optional, defaults to https://api.uptime-monitor.io
}
```

Configuration can also be provided via environment variables:
- `UPTIME_API_KEY` - API key for authentication
- `UPTIME_BASE_URL` - Base URL for the API

### Creating an HTTPS Monitor

```hcl
resource "uptime_monitor" "api_health" {
  name          = "API Health Check"
  url           = "https://api.example.com/health"
  type          = "https"
  check_interval = 60
  timeout       = 30
  regions       = ["us-east", "eu-west", "ap-southeast"]

  https_settings {
    method                        = "GET"
    expected_status_codes        = "200,201-204"
    check_certificate_expiration = true
    follow_redirects            = true
    
    request_headers = {
      "Authorization" = "Bearer token"
      "Content-Type"  = "application/json"
    }
    
    expected_response_body = "healthy"
    
    expected_response_headers = {
      "Content-Type" = "application/json"
    }
  }
}
```

### Creating a TCP Monitor

```hcl
resource "uptime_monitor" "db_check" {
  name          = "Database Connection"
  url           = "tcp://db.example.com:5432"
  type          = "tcp"
  check_interval = 120
  timeout       = 10
  regions       = ["us-east", "eu-west"]
}
```

### Creating a Ping Monitor

```hcl
resource "uptime_monitor" "server_ping" {
  name          = "Server Ping"
  url           = "ping://server.example.com"
  type          = "ping"
  check_interval = 30
  timeout       = 5
  regions       = ["us-east"]
}
```

## Resource Reference

### `uptime_monitor`

#### Arguments

- `name` (String, Required) - Display name for the monitor
- `url` (String, Required) - The URL or endpoint to monitor
- `type` (String, Required) - Monitor type: "https", "tcp", or "ping"
- `check_interval` (Number, Optional) - Check interval in seconds (default: 60)
- `timeout` (Number, Optional) - Request timeout in seconds (default: 30)
- `regions` (List of String, Optional) - List of regions to perform checks from

#### HTTPS Settings Block

When `type = "https"`, you can configure additional HTTPS-specific options:

- `method` (String, Optional) - HTTP method to use (default: "GET")
- `expected_status_codes` (String, Optional) - Expected HTTP status codes (e.g., "200", "200-299", "200,201,301")
- `check_certificate_expiration` (Boolean, Optional) - Whether to check SSL certificate expiration (default: true)
- `follow_redirects` (Boolean, Optional) - Whether to follow HTTP redirects (default: true)
- `request_headers` (Map of String, Optional) - HTTP headers to send with the request
- `request_body` (String, Optional) - HTTP request body (for POST/PUT requests)
- `expected_response_body` (String, Optional) - Expected substring in the response body
- `expected_response_headers` (Map of String, Optional) - Expected HTTP response headers

#### Attributes

- `id` (String) - Monitor identifier

## Development

### Requirements

- Go 1.23+
- Terraform 1.0+

### Building

```bash
# Format code
make fmt

# Run tests
make test

# Build provider
make build

# Run all checks
make all
```

### Testing

Run unit tests:
```bash
make test
```

Run acceptance tests (requires running API):
```bash
make testacc
```

## Architecture

The provider is structured as follows:

- `internal/provider/` - Main provider implementation and configuration
- `internal/client/` - API client for communicating with the Uptime Monitor service
- `internal/resources/` - Terraform resource implementations
- `examples/` - Example Terraform configurations
- `docs/` - Generated documentation

## API Integration

This provider interfaces with your existing Uptime Monitor API endpoints:

- `POST /api/monitors` - Create monitor
- `GET /api/monitors/{id}` - Get monitor
- `PUT /api/monitors/{id}` - Update monitor  
- `DELETE /api/monitors/{id}` - Delete monitor
- `GET /api/monitors` - List monitors

Authentication is handled via Bearer token in the Authorization header.

## Contributing

1. Make changes to the provider code
2. Run tests: `make test`
3. Build and test locally: `make build && make install`
4. Create example configurations to test functionality
5. Update documentation as needed

## Distribution

For production use:

1. Build binaries for target platforms: `make dist`
2. Host binaries on your infrastructure (S3, GitHub releases, etc.)
3. Provide installation instructions to customers
4. Consider setting up a private Terraform registry for easier distribution