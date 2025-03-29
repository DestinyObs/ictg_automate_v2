# Generate an SSH key pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a key pair in AWS
resource "aws_key_pair" "ictg_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Store the private key locally
resource "local_file" "ssh_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/ictg_automate_key.pem"
}

# Create a security group
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

# Create an EC2 instance
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ictg_key.key_name
  security_groups = [aws_security_group.ictg_automate_sg.name]

  # Run a script during instance startup
  user_data = file("${path.module}/app-setup.sh")

  # File Provisioner to upload script
  provisioner "file" {
    source      = "app-setup.sh"
    destination = "/home/ubuntu/app-setup.sh"
  }

  # Remote execution provisioner to run the script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/app-setup.sh",
      "sudo /home/ubuntu/app-setup.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ec2_key.private_key_pem
    host        = self.public_ip
  }

  tags = {
    Name = "ICTG App Server"
  }
}
