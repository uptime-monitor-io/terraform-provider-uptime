terraform {
  required_providers {
    uptime = {
      source = "registry.terraform.io/uptime-monitor-io/uptime"
    }
  }
}

# Configure the Uptime Monitor provider using environment variables
provider "uptime" {
  # Configuration options
  # api_key and base_url can be set via environment variables:
  # export UPTIME_API_KEY="your-api-key"
  # export UPTIME_BASE_URL="https://uptime-monitor.io" (optional)
}

# Or configure explicitly
provider "uptime" {
  api_key  = "your-api-key"
  base_url = "https://uptime-monitor.io" # Optional, defaults to production API
}