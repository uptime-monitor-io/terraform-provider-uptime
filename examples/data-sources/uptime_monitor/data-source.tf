# Look up a monitor by ID
data "uptime_monitor" "example" {
  id = "12345"
}

# Use the monitor data in other resources
resource "uptime_status_page" "status" {
  name        = "Public Status"
  monitor_ids = [data.uptime_monitor.example.id]
}

output "monitor_url" {
  value = data.uptime_monitor.example.url
}

output "monitor_interval" {
  value = data.uptime_monitor.example.interval
}