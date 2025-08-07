# Look up a status page by ID
data "uptime_status_page" "example" {
  id = "abc123"
}

# Use the status page data
output "status_page_name" {
  value = data.uptime_status_page.example.name
}

output "status_page_url" {
  value = data.uptime_status_page.example.url
}

output "status_page_custom_domain" {
  value = data.uptime_status_page.example.custom_domain
}

output "status_page_monitors" {
  value = data.uptime_status_page.example.monitors
}

output "status_page_period" {
  value = data.uptime_status_page.example.period
}

output "show_incident_reasons" {
  value = data.uptime_status_page.example.show_incident_reasons
}