# Look up a status page by ID
data "uptime_status_page" "example" {
  id = "abc123"
}

# Use the status page data
output "status_page_url" {
  value = data.uptime_status_page.example.custom_domain
}

output "status_page_monitors" {
  value = data.uptime_status_page.example.monitor_ids
}

output "company_name" {
  value = data.uptime_status_page.example.company_name
}