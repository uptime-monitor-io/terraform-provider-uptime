# Look up a contact by ID
data "uptime_contact" "example" {
  id = "67890"
}

# Use the contact data
output "contact_name" {
  value = data.uptime_contact.example.name
}

output "contact_channel" {
  value = data.uptime_contact.example.channel
}

output "contact_active" {
  value = data.uptime_contact.example.active
}