# Email contact example
resource "uptime_contact" "email_contact" {
  name    = "DevOps Team Email"
  channel = "email"

  email_settings = {
    email = "devops@example.com"
  }
}

# SMS contact example
resource "uptime_contact" "sms_contact" {
  name             = "On-Call Phone"
  channel          = "sms"
  down_alerts_only = true

  sms_settings = {
    phone = "+1234567890"
  }
}

# Slack webhook contact example
resource "uptime_contact" "slack_contact" {
  name    = "Slack Alerts"
  channel = "slack"

  slack_settings = {
    webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
  }
}

# Discord webhook contact example
resource "uptime_contact" "discord_contact" {
  name    = "Discord Notifications"
  channel = "discord"

  discord_settings = {
    webhook_url = "https://discord.com/api/webhooks/000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
}

# PagerDuty integration example
resource "uptime_contact" "pagerduty_contact" {
  name    = "PagerDuty Integration"
  channel = "pagerduty"

  pagerduty_settings = {
    integration_key        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    auto_resolve_incidents = true

    severity_mapping = {
      critical = "critical"
      high     = "error"
      medium   = "warning"
      low      = "info"
    }
  }
}

# Opsgenie integration example
resource "uptime_contact" "opsgenie_contact" {
  name    = "Opsgenie Alerts"
  channel = "opsgenie"

  opsgenie_settings = {
    api_key           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    eu_instance       = false
    auto_close_alerts = true
    priority          = "P2"
    tags              = ["uptime-monitor", "production"]

    responders = [
      {
        type = "team"
        name = "DevOps Team"
      },
      {
        type     = "user"
        username = "john.doe@example.com"
      }
    ]
  }
}

# Webhook contact example
resource "uptime_contact" "webhook_contact" {
  name    = "Custom Webhook"
  channel = "webhook"

  webhook_settings = {
    url = "https://api.example.com/webhooks/monitoring"
  }
}

# Incident.io integration example
resource "uptime_contact" "incidentio_contact" {
  name    = "Incident.io"
  channel = "incidentio"

  incidentio_settings = {
    webhook_url            = "https://api.incident.io/v1/webhooks/xxxxxxxx"
    bearer_token           = "inc_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    auto_resolve_incidents = true
  }
}

# Zendesk integration example
resource "uptime_contact" "zendesk_contact" {
  name    = "Zendesk Support"
  channel = "zendesk"

  zendesk_settings = {
    subdomain          = "mycompany"
    email              = "support@mycompany.com"
    api_token          = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    priority           = "high"
    auto_solve_tickets = true
    tags               = ["monitoring", "automated"]

    custom_fields = [
      {
        id    = 360000000000
        value = "production"
      }
    ]
  }
}