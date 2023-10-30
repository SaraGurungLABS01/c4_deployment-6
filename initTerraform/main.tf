# configure aws provider
provider "aws" {
  access_key = var.access_key 
  secret_key = var.secret_key
  region     = var.region
  #profile = "Admin"
}

################################-RESOURCE BLOCK-#########################################

###################################-CREATING EC2 INSTANCES-###################################

#EC2 instance 1
resource "aws_instance" "bank_app" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.dep6_east_sg.id]
  subnet_id                   = aws_subnet.Deployment6_public_subnet1_east.id
  key_name                    = var.key_name
  associate_public_ip_address = true # Enable Auto-assign public IP

 user_data = "${file("appsetup.sh")}"

  tags = {
    "Name" : "Bank_App_East1"
  }

}

#EC2 instance 2

resource "aws_instance" "bank_app2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.dep6_east_sg.id]
  subnet_id                   = aws_subnet.Deployment6_public_subnet2_east.id
  key_name                    = var.key_name
  associate_public_ip_address = true # Enable Auto-assign public IP

 user_data = "${file("appsetup.sh")}"

  tags = {
    "Name" : "Bank_App_East2"
  }

}


######################################-VPC-###############################################

#create vpc

resource "aws_vpc" "Deployment6_VPC_us_east" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Deployment6_VPC_us_east"
  }
}



#######################################-SUBNETS-######################################################

#create 2 subnets

# Subnet-1

resource "aws_subnet" "Deployment6_public_subnet1_east" {
  vpc_id            = aws_vpc.Deployment6_VPC_us_east.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "Deployment6_public_subnet1_east"
  }
}

#Subnet-2

resource "aws_subnet" "Deployment6_public_subnet2_east" {
  vpc_id            = aws_vpc.Deployment6_VPC_us_east.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Deployment6_public_subnet2_east"
  }
}

##################################-SECURITY GROUPS-#######################################

# create security groups

#Security Group 

resource "aws_security_group" "dep6_east_sg" {
  vpc_id = aws_vpc.Deployment6_VPC_us_east.id


  ingress {
    description = "allow incoming SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow incoming traffic on port 8080"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    "Name" : "dep6_east_sg"
    "Terraform" : "true"
  }

}

#############################-INTERNET GATEWAY-####################################

#create internet gateway

resource "aws_internet_gateway" "Dep6_east_gw" {
  vpc_id = aws_vpc.Deployment6_VPC_us_east.id

  tags = {
    Name = "IGW_D6_east"
  }
}

#############################- ROUTE TABLE-######################################

#create route table


resource "aws_default_route_table" "Dep6_east_RT" {
  default_route_table_id = aws_vpc.Deployment6_VPC_us_east.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Dep6_east_gw.id
  }
}




################################-OUTPUT BLOCK-##########################################

output "instance_ip_1" {
  value = aws_instance.bank_app.public_ip
}

output "instance_ip_2" {
  value = aws_instance.bank_app2.public_ip
}
