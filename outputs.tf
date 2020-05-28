output "server_public_ip" {
  description = "Public IP address of the server"
  value       = aws_instance.iac-demo[*].public_ip
}


# Immutable infrastructure
# => Destroy something then create something new
#
# Mutable infrastructure
# Can be changed: 1 server running => modify running server without bringing it down (without destroying it)
