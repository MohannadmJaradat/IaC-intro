terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48"
    }
  }

  required_version = ">= 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

# The main.tf file is where you dclare variables, you don't really assign
# them values here, you do that in the terraform.tfvars file.
variable "sample_public_key" {
  description = "Sample environment public key value"
  type        = string
}

# The first resouce we define here is a data block, which will specify
# which ami we will use for our server.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# The next resource we define is the key pair that will be used to access
# the server via SSH.
resource "aws_key_pair" "sample_key" {
  key_name   = "sample-key"
  public_key = var.sample_public_key

  tags = {
    "Name" = "sample_public_key"
  }
}

# Finally we will create the actual VM.
resource "aws_instance" "sample_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0d2411db69a112a30"]
  key_name               = aws_key_pair.sample_key.key_name # Reference the key pair created above, we specified the resource type, then the resource name, and finally the attribute we want to use.

  tags = {
    "Name" = "sample_server"
  }
}

output "sample_server_dns" {
  value = aws_instance.sample_server.public_dns # <resouce_type>.<resource_name>.<attribute>
}
