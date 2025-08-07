# Basic status page example
resource "uptime_status_page" "public_status" {
  name = "Public Status Page"
  
  # Link monitors to display on the status page (required, 1-20 monitors)
  monitors = [
    uptime_monitor.api_monitor.id,
    uptime_monitor.website_monitor.id
  ]
  
  # Optional: Time period for uptime statistics (defaults to 7 days)
  period = 30  # Can be 7, 30, or 90 days
}

# Status page with custom domain and authentication
resource "uptime_status_page" "advanced_status" {
  name          = "Service Health Dashboard"
  custom_domain = "status.myapp.com"
  
  monitors = [
    uptime_monitor.frontend.id,
    uptime_monitor.backend.id,
    uptime_monitor.database.id
  ]
  
  # Optional: Show incident reasons publicly
  show_incident_reasons = true
  
  # Optional: Protect with basic authentication
  basic_auth = "admin:SecurePassword123"  # username:password format
  
  # Optional: Use 90-day uptime period
  period = 90
}

# Example monitors to link to status page
resource "uptime_monitor" "api_monitor" {
  name           = "API Endpoint"
  url            = "https://api.example.com/health"
  check_interval = 60
  type           = "https"
}

resource "uptime_monitor" "website_monitor" {
  name           = "Main Website"
  url            = "https://example.com"
  check_interval = 300
  type           = "https"
}

resource "uptime_monitor" "frontend" {
  name           = "Customer Portal"
  url            = "https://app.myapp.com"
  check_interval = 60
  type           = "https"
}

resource "uptime_monitor" "backend" {
  name           = "API Service"
  url            = "https://api.myapp.com/status"
  check_interval = 60
  type           = "https"
}

resource "uptime_monitor" "database" {
  name           = "Database Connection"
  url            = "tcp://db.myapp.internal:5432"
  check_interval = 60
  type           = "tcp"
}