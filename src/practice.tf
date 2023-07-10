provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# resource "<aws>_<resource_type>" "name" {
#   config options
#   key = "value"
# }

# resource "aws_instance" "my-test-server2" {
#   ami           = "ami-03f65b8614a860c29"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ubuntu"
#   }
# }

# resource "aws_vpc" "first-vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "production"
#   }
# }

# resource "aws_subnet" "subnet-1" {
#   vpc_id     = aws_vpc.first-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "prod-subnet"
#   }
# }
