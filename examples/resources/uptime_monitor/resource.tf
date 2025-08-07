resource "uptime_monitor" "example" {
  name           = "Example Website"
  url            = "https://example.com"
  type           = "https"
  check_interval = 60
  timeout        = 30
  regions        = ["us-east-1", "eu-west-1"]
  
  https_settings = {
    method                       = "get"
    expected_status_codes        = "200"
    check_certificate_expiration = true
    follow_redirects             = true
  }
}