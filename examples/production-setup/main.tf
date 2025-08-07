# Production-Ready Uptime Monitoring Setup
# This example demonstrates a complete production monitoring setup

terraform {
  required_providers {
    uptime = {
      source  = "uptime-monitor-io/uptime"
      version = "~> 0.0.3"
    }
  }
}

provider "uptime" {
  # API key should be set via environment variable:
  # export UPTIME_API_KEY="your-api-key"
}

# ============================================================================
# CONTACTS
# ============================================================================

resource "uptime_contact" "ops_team" {
  name  = "Operations Team"
  email = "ops@example.com"
}

resource "uptime_contact" "dev_team" {
  name  = "Development Team"
  email = "dev@example.com"
}

resource "uptime_contact" "critical_alerts" {
  name  = "Critical Alerts"
  email = "critical@example.com"
}

# ============================================================================
# WEBSITE MONITORS
# ============================================================================

resource "uptime_monitor" "main_website" {
  name           = "Main Website"
  url            = "https://www.example.com"
  type           = "https"
  check_interval = 60
  timeout        = 30
  regions        = ["us-east-1", "eu-west-1", "ap-southeast-1"]
  fail_threshold = 2
  
  https_settings = {
    method                       = "get"
    expected_status_codes        = "200,301"
    check_certificate_expiration = true
    follow_redirects             = true
    request_headers = {
      "User-Agent" = "UptimeMonitor/Production"
    }
  }
  
  contacts = [
    uptime_contact.ops_team.id,
    uptime_contact.critical_alerts.id
  ]
}

resource "uptime_monitor" "blog" {
  name           = "Company Blog"
  url            = "https://blog.example.com"
  type           = "https"
  check_interval = 300  # Less critical, check every 5 minutes
  timeout        = 30
  regions        = ["us-east-1", "eu-west-1"]
  
  https_settings = {
    method                       = "get"
    expected_status_codes        = "200"
    check_certificate_expiration = true
    follow_redirects             = true
  }
  
  contacts = [uptime_contact.ops_team.id]
}

# ============================================================================
# API MONITORS
# ============================================================================

resource "uptime_monitor" "api_health" {
  name           = "API Health Check"
  url            = "https://api.example.com/health"
  type           = "https"
  check_interval = 30  # Critical API, check every 30 seconds
  timeout        = 10
  regions        = ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
  fail_threshold = 2
  
  https_settings = {
    method                = "get"
    expected_status_codes = "200"
    expected_response_body = "\"status\":\"healthy\""
    request_headers = {
      "Accept" = "application/json"
    }
  }
  
  contacts = [
    uptime_contact.dev_team.id,
    uptime_contact.critical_alerts.id
  ]
}

resource "uptime_monitor" "api_auth" {
  name           = "API Authentication Service"
  url            = "https://api.example.com/auth/status"
  type           = "https"
  check_interval = 60
  timeout        = 10
  regions        = ["us-east-1", "eu-west-1"]
  
  https_settings = {
    method                = "post"
    expected_status_codes = "200,401"  # 401 is expected without auth
    request_headers = {
      "Content-Type" = "application/json"
    }
    request_body = jsonencode({
      test = true
    })
  }
  
  contacts = [uptime_contact.dev_team.id]
}

# ============================================================================
# DATABASE MONITORS
# ============================================================================

resource "uptime_monitor" "postgres_primary" {
  name           = "PostgreSQL Primary"
  url            = "db-primary.example.com:5432"
  type           = "tcp"
  check_interval = 120
  timeout        = 5
  regions        = ["us-east-1"]
  fail_threshold = 3
  
  contacts = [
    uptime_contact.ops_team.id,
    uptime_contact.critical_alerts.id
  ]
}

resource "uptime_monitor" "postgres_replica" {
  name           = "PostgreSQL Replica"
  url            = "db-replica.example.com:5432"
  type           = "tcp"
  check_interval = 300
  timeout        = 5
  regions        = ["us-east-1"]
  
  contacts = [uptime_contact.ops_team.id]
}

resource "uptime_monitor" "redis_cache" {
  name           = "Redis Cache"
  url            = "redis.example.com:6379"
  type           = "tcp"
  check_interval = 120
  timeout        = 3
  regions        = ["us-east-1", "us-west-2"]
  
  contacts = [uptime_contact.ops_team.id]
}

# ============================================================================
# INTERNAL SERVICES
# ============================================================================

resource "uptime_monitor" "elasticsearch" {
  name           = "Elasticsearch Cluster"
  url            = "https://es.example.com:9200/_cluster/health"
  type           = "https"
  check_interval = 120
  timeout        = 10
  regions        = ["us-east-1"]
  
  https_settings = {
    method                = "get"
    expected_status_codes = "200"
    expected_response_body = "\"status\":\"green\""
    request_headers = {
      "Authorization" = "Basic ${base64encode("elastic:${var.elastic_password}")}"
    }
  }
  
  contacts = [uptime_contact.ops_team.id]
}

# ============================================================================
# STATUS PAGE
# ============================================================================

resource "uptime_status_page" "public_status" {
  name        = "Service Status"
  slug        = "status"
  description = "Real-time status of Example.com services"
  
  monitor_ids = [
    uptime_monitor.main_website.id,
    uptime_monitor.api_health.id,
    uptime_monitor.blog.id
  ]
}

resource "uptime_status_page" "internal_status" {
  name        = "Internal Infrastructure Status"
  slug        = "internal-status"
  description = "Status page for internal services and databases"
  
  monitor_ids = [
    uptime_monitor.postgres_primary.id,
    uptime_monitor.postgres_replica.id,
    uptime_monitor.redis_cache.id,
    uptime_monitor.elasticsearch.id
  ]
}

# ============================================================================
# OUTPUTS
# ============================================================================

output "status_page_url" {
  value       = "https://status.example.com/${uptime_status_page.public_status.slug}"
  description = "Public status page URL"
}

output "critical_monitors" {
  value = {
    website = uptime_monitor.main_website.id
    api     = uptime_monitor.api_health.id
    database = uptime_monitor.postgres_primary.id
  }
  description = "IDs of critical monitors"
}

output "all_monitor_ids" {
  value = {
    main_website      = uptime_monitor.main_website.id
    blog             = uptime_monitor.blog.id
    api_health       = uptime_monitor.api_health.id
    api_auth         = uptime_monitor.api_auth.id
    postgres_primary = uptime_monitor.postgres_primary.id
    postgres_replica = uptime_monitor.postgres_replica.id
    redis_cache      = uptime_monitor.redis_cache.id
    elasticsearch    = uptime_monitor.elasticsearch.id
  }
  description = "Map of all monitor IDs"
}