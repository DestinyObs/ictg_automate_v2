provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "ictg_automate_sg" {
  name        = var.security_group_name
  description = "Allow SSH, HTTP, and necessary ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for SSH (limit for security)
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Backend service
  }

  ingress {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Frontend service
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # PostgreSQL
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.ictg_automate_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              # Ensure the SSH key has correct permissions
              chmod 400 /home/ubuntu/${var.key_name}.pem
              
              # Make setup script executable
              chmod +x /home/ubuntu/app-setup.sh
              
              # Run the setup script with sudo
              sudo /home/ubuntu/app-setup.sh
              EOF

  provisioner "file" {
    source      = "app-setup.sh"
    destination = "/home/ubuntu/app-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/app-setup.sh",
      "sudo /home/ubuntu/app-setup.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("ictg_automate_key.pem")
    host        = self.public_ip
  }

  tags = {
    Name = "ICTG App Server"
  }
}
