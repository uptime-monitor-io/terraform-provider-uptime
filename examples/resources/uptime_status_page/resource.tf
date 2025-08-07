# Basic status page example
resource "uptime_status_page" "public_status" {
  name             = "Public Status Page"
  custom_domain    = "status.example.com"
  company_name     = "Example Corp"
  company_url      = "https://example.com"
  contact_email    = "support@example.com"
  company_logo_url = "https://example.com/logo.png"
  timezone         = "America/New_York"
  
  # Link monitors to display on the status page
  monitor_ids = [
    uptime_monitor.api_monitor.id,
    uptime_monitor.website_monitor.id
  ]
}

# Status page with custom branding
resource "uptime_status_page" "branded_status" {
  name               = "Customer Portal Status"
  custom_domain      = "status.myapp.com"
  company_name       = "MyApp Inc"
  company_url        = "https://myapp.com"
  contact_email      = "ops@myapp.com"
  company_logo_url   = "https://cdn.myapp.com/assets/logo.svg"
  timezone           = "UTC"
  hide_powered_by    = true
  allow_search_index = false
  
  monitor_ids = [
    uptime_monitor.frontend.id,
    uptime_monitor.backend.id,
    uptime_monitor.database.id
  ]
}

# Example monitors to link to status page
resource "uptime_monitor" "api_monitor" {
  name     = "API Endpoint"
  url      = "https://api.example.com/health"
  interval = 60
  type     = "HTTPS"
}

resource "uptime_monitor" "website_monitor" {
  name     = "Main Website"
  url      = "https://example.com"
  interval = 300
  type     = "HTTPS"
}

resource "uptime_monitor" "frontend" {
  name     = "Customer Portal"
  url      = "https://app.myapp.com"
  interval = 60
  type     = "HTTPS"
}

resource "uptime_monitor" "backend" {
  name     = "API Service"
  url      = "https://api.myapp.com/status"
  interval = 60
  type     = "HTTPS"
}

resource "uptime_monitor" "database" {
  name     = "Database Connection"
  url      = "tcp://db.myapp.internal:5432"
  interval = 60
  type     = "TCP"
}