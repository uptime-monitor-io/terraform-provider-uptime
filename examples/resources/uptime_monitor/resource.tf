resource "uptime_monitor" "example" {
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

# Example contact for monitor notifications
resource "uptime_contact" "main" {
  name    = "DevOps Team"
  channel = "email"

  email_settings = {
    email = "devops@example.com"
  }
}