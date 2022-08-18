output "server_public_ip" {
  value = aws_instance.server.public_ip
}

output "lakefs_server_ui" {
  value = "http://${aws_instance.server.public_ip}:8000"
}