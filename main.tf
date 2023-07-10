provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# variable "subnet_prefix" {
#   description = "cidr block for the subnet"
#   #default = "10.0.1.0/16" 
#   type = string
# }

# 1. Create a VPC
resource "aws_vpc" "practice-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "practice-project"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "practice-gw" {
  vpc_id = aws_vpc.practice-vpc.id

  tags = {
    Name = "practice-project"
  }
}

# 3. Create a custom route table
resource "aws_route_table" "practice-route-table" {
  vpc_id = aws_vpc.practice-vpc.id

  route {
    cidr_block = var.subnet_prefix
    gateway_id = aws_internet_gateway.practice-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.practice-gw.id
  }

  tags = {
    Name = "practice-project"
  }
}

# 4. Create a subnet
resource "aws_subnet" "practice-subnet" {
  vpc_id            = aws_vpc.practice-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "practice-project"
  }
}

# 5. Associate subnet with route table
resource "aws_main_route_table_association" "practice-a" {
  vpc_id         = aws_vpc.practice-vpc.id
  route_table_id = aws_route_table.practice-route-table.id
}

# 6. Create securrity group to allow port 22, 80 and 443
resource "aws_security_group" "practice-allow_tls" {
  name        = "allow_web_trafic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.practice-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_prefix]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnet_prefix]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_prefix]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_prefix]
  }

  tags = {
    Name = "practice-allow-web"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "practice-web-server-nic" {
  subnet_id       = aws_subnet.practice-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.practice-allow_tls.id]
}

# 8. Assign am elastic IP to the network interface created in step 7 
resource "aws_eip" "practice-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.practice-web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.practice-gw]
}

output "my_server_public_ip" {
  value = aws_eip.practice-eip.public_ip
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "practice-web-server" {
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t2.micro"
  availability_zone = "us-west-2a"
  key_name          = "practice-server"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.practice-web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very terraform web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "practice-web-server"
  }
}

output "server_private_ip" {
  value = aws_instance.practice-web-server.private_ip
}
