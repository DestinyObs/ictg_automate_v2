output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "private_key_file" {
  description = "Path to the private key file"
  value       = local_file.ssh_key.filename
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.ictg_automate_sg.id
}
