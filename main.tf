provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-ci-pipeline" 
    key    = "prod/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

variable "dockerhub_username" {
  description = "The Docker Hub username passed from GitHub Actions"
  type        = string
}

resource "aws_security_group" "web_sg" {
  name = "static-site-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0224ce6f9504665ee" # Standard Ubuntu AMI
  instance_type = "t3.micro"
  security_groups = [aws_security_group.web_sg.name]

  # This cloud-init script runs automatically when the server boots
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d --name static-site -p 80:80 ${var.dockerhub_username}/my-static-site:latest
              EOF
}