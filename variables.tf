variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  default     = "ami-0c7217cdde317cfec"  # Update for your region
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "ictg_automate_key"
}

variable "security_group_name" {
  description = "Security group for EC2 instance"
  default     = "ictg_automate_sg"
}
