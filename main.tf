# Updated to include 3 EC2 instances.
# Added second line on 31 Jan 2024 0200AM.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sctp-ce5-tfstate-bucket-1"
    key = "soon.tfstate"
    region = "us-east-1"
  }
}

# 00. Create an SNS topic.
resource "aws_sns_topic" "user_updates" {
  name = "soon-updates-topic"
}

# 01. Create a VPC.
resource "aws_vpc" "slf_vpc_a" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "soon01 - VPC A"
  }
}

# 02. Create a public subnet 1 within VPC A.
resource "aws_subnet" "slf_vpc_a_pu_subnet_1" {
  vpc_id = aws_vpc.slf_vpc_a.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "soon02 - Public subnet 1 within VPC A"
  }
}

# 03. Create a public subnet 2 within VPC A.
resource "aws_subnet" "slf_vpc_a_pu_subnet_2" {
  vpc_id = aws_vpc.slf_vpc_a.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "soon03 - Public subnet 2 within VPC A"
  }
}

# 04. Create a private subnet 1 within VPC A.
resource "aws_subnet" "slf_vpc_a_pr_subnet_1" {
  vpc_id = aws_vpc.slf_vpc_a.id
  cidr_block = "10.0.11.0/24"
  tags = {
    Name = "soon04 - Private subnet 1 within VPC A"
  }
}

# 05. Create a private subnet 2 within VPC A.
resource "aws_subnet" "slf_vpc_a_pr_subnet_2" {
  vpc_id = aws_vpc.slf_vpc_a.id
  cidr_block = "10.0.12.0/24"
  tags = {
    Name = "soon05 - Private subnet 2 within VPC A"
  }
}

# 06. Create a internet gateway 1 within VPC A.
resource "aws_internet_gateway" "slf_vpc_a_igw_1" {
  vpc_id = aws_vpc.slf_vpc_a.id
  tags = {
    Name = "soon06 - Internet Gateway 1 within VPC A"
  }
}

# 07. Create a route table 1 within VPC A.
resource "aws_route_table" "slf_vpc_a_rt_1" {
  vpc_id = aws_vpc.slf_vpc_a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.slf_vpc_a_igw_1.id
  }
  tags = {
    Name = "soon07 - Custom Route Table 1 within VPC A"
  }
}

# 08. Create a route table association for private subnet 1.
resource "aws_route_table_association" "slf_vpc_a_rta_1" {
  subnet_id = aws_subnet.slf_vpc_a_pu_subnet_1.id
  route_table_id = aws_route_table.slf_vpc_a_rt_1.id
}

# 09. Create a security group 1 for public subnet 1.
resource "aws_security_group" "slf_vpc_a_pu_subnet_1_sg_1" {
    name = "Custom Security Group for Public Subnet 1"
    description = "Custom Security Group for Public Subnet 1"
    vpc_id = aws_vpc.slf_vpc_a.id
  
    ingress {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  
    ingress {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
      description      = "ICMP"
      # -1 to allow ALL ports.
      from_port        = -1
      to_port          = -1
      protocol         = "icmp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  
    tags = {
      Name = "soon09 - Security Group 1 for Public Subnet 1"
    }
  }

# 10A. Create first EC2 instance within public subnet 1.
resource "aws_instance" "pu_subnet_1_ec2_1" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.slf_vpc_a_pu_subnet_1.id
  vpc_security_group_ids = [aws_security_group.slf_vpc_a_pu_subnet_1_sg_1.id]
    user_data = <<EOF
#!/bin/bash
echo "Updating the yum repositories..."
sudo yum update -y
echo "Installing the pip utility..."
sudo yum install pip -y
echo "Installing ansible..."
sudo python3 -m pip install --user ansible
echo "All done..."
EOF
  tags = {
    Name = "soon10A - Webserver-1 - EC2 Instance 1 for Public Subnet 1"
  }
}

# 10B. Create second EC2 instance within public subnet 1.
resource "aws_instance" "pu_subnet_1_ec2_2" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.slf_vpc_a_pu_subnet_1.id
  vpc_security_group_ids = [aws_security_group.slf_vpc_a_pu_subnet_1_sg_1.id]
  tags = {
    Name = "soon10B - Webserver-2 - EC2 Instance 2 for Public Subnet 1"
  }
}

# 10C. Create third EC2 instance within public subnet 1.
resource "aws_instance" "pu_subnet_1_ec2_3" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.slf_vpc_a_pu_subnet_1.id
  vpc_security_group_ids = [aws_security_group.slf_vpc_a_pu_subnet_1_sg_1.id]
  tags = {
    Name = "soon10C - Ansibleserver - EC2 Instance 3 for Public Subnet 1"
  }
}

# 11. Create a security group 1 for private subnet 1.
# ACTUALLY THE SECURITY GROUP SHOULD BE ATTACHED TO EC2 INSTANCE AND NOT TO VPC.
resource "aws_security_group" "slf_vpc_a_pr_subnet_1_sg_1" {
    name = "Custom Security Group for Private Subnet"
    description = "Custom Security Group for Private Subnet"
    vpc_id = aws_vpc.slf_vpc_a.id
  
    ingress {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  
    tags = {
      Name = "soon11 - Security Group 1 for Private Subnet 1"
    }
  }

# 12. Create an EC2 instance within private subnet 1.
resource "aws_instance" "pr_subnet_1_ec2_1" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.slf_vpc_a_pr_subnet_1.id
  vpc_security_group_ids = [aws_security_group.slf_vpc_a_pr_subnet_1_sg_1.id]
  tags = {
    Name = "soon12 - EC2 Instance 1 for Private Subnet 1"
  }
}

/*** This segment does not work. Please ignore it for the time being.
resource "aws_instance" "pr_subnet_1_ec2_1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.slf_vpc_a_pr_subnet_1.id
  vpc_security_group_ids = [aws_security_group.slf_vpc_a_pr_subnet_1_sg_1]
  tags = {
    Name = "EC2 Instance for Private Subnet 1"
  }
}

data "aws_ami_ids" "ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/ubuntu-*-*-amd64-server-*"]
  }
}
***/
