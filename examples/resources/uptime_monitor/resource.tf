# HTTPS monitor example
resource "uptime_monitor" "https_monitor" {
  name           = "Example Website"
  url            = "https://example.com"
  type           = "https"
  check_interval = 60
  timeout        = 30
  fail_threshold = 2
  regions        = ["us-east-1", "eu-west-1"]
  contacts       = [uptime_contact.main.id]
  
  https_settings = {
    method                       = "GET"
    expected_status_codes        = "200"
    check_certificate_expiration = true
    follow_redirects             = true
  }
}

# TCP monitor example
resource "uptime_monitor" "tcp_monitor" {
  name           = "PostgreSQL Database"
  url            = "tcp://db.example.com:5432"
  type           = "tcp"
  check_interval = 120
  timeout        = 10
  fail_threshold = 3
  regions        = ["us-east-1"]
  contacts       = [uptime_contact.main.id]
  
  # TCP monitors have minimal configuration
  # They simply check if the port is open and accepting connections
  tcp_settings = {}
}

# Ping monitor example
resource "uptime_monitor" "ping_monitor" {
  name           = "Network Gateway"
  url            = "gateway.example.com"  # Can also use IP address like "192.168.1.1"
  type           = "ping"
  check_interval = 60
  timeout        = 5
  fail_threshold = 2
  regions        = ["us-east-1", "eu-west-1"]
  contacts       = [uptime_contact.main.id]
  
  # Ping monitors have minimal configuration
  # They send ICMP packets to check if the host is reachable
  ping_settings = {}
}

# Example contact for monitor notifications
resource "uptime_contact" "main" {
  name    = "DevOps Team"
  channel = "email"

  email_settings = {
    email = "devops@example.com"
  }
}