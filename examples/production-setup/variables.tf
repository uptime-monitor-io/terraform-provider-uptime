# Variable definitions for production monitoring setup

variable "elastic_password" {
  description = "Password for Elasticsearch authentication"
  type        = string
  sensitive   = true
}

variable "notification_emails" {
  description = "Email addresses for different notification groups"
  type = object({
    ops      = string
    dev      = string
    critical = string
  })
  default = {
    ops      = "ops@example.com"
    dev      = "dev@example.com"
    critical = "critical@example.com"
  }
}

variable "monitoring_regions" {
  description = "Regions to monitor from"
  type = object({
    global   = list(string)
    us_only  = list(string)
    critical = list(string)
  })
  default = {
    global   = ["us-east-1", "eu-west-1", "ap-southeast-1"]
    us_only  = ["us-east-1"]
    critical = ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
  }
}

variable "check_intervals" {
  description = "Check intervals for different service tiers"
  type = object({
    critical = number
    standard = number
    low      = number
  })
  default = {
    critical = 30   # 30 seconds
    standard = 60   # 1 minute
    low      = 300  # 5 minutes
  }
}