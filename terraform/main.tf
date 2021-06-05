provider "aws" {
  region     = "us-east-1"
  access_key = "<ENTER ACCESS KEY>"
  secret_key = "<ENTER SECRET KEY>"
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
}

# 1. Create vpc
resource "aws_vpc" "prod-vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
     Name = "production"
   }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.prod-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
   vpc_id = aws_vpc.prod-vpc.id
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
}
   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.gw.id
   }
   tags = {
     Name = "Prod"
   }
}

# 4. Create subnets  
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = var.subnet_prefix[0].name
  }
}


# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet-1.id
   route_table_id = aws_route_table.prod-route-table.id
 }

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.prod-vpc.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
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
     Name = "allow_web"
   }
}

# 7. Create N/w interface
resource "aws_network_interface" "web-server-nic-1" {
   subnet_id       = aws_subnet.subnet-1.id
   private_ips     = ["10.0.1.50"]
   security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "one" {
   vpc                       = true
   network_interface         = aws_network_interface.web-server-nic-1.id
   associate_with_private_ip = "10.0.1.50"
   depends_on                = [aws_internet_gateway.gw]
}

# 8. Create template data source for referring the shell script that installs nginx 
data "template_file" "user_data" {
	template = "${file("script.sh")}"
}


 #10 . Create aws iam role
resource "aws_iam_role" "Conversion_EC2_service" {
  name = "conversion_ec2_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com","codedeploy.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


#11. Attach policy
resource "aws_iam_role_policy_attachment" "EC2_AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.Conversion_EC2_service.name
}

resource "aws_iam_instance_profile" "EC2_AWSCodeDeployProfile" {
  name = "DeploymentProfile"
  role = "${aws_iam_role.Conversion_EC2_service.name}"
}

resource "aws_codedeploy_app" "MyApp2" {
  name = "MyApp2"
}

resource "aws_codedeploy_deployment_group" "MyDeploymentGroup2" {
  app_name              = aws_codedeploy_app.MyApp2.name
  deployment_group_name = "MyDeploymentGroup2"
  service_role_arn      = aws_iam_role.Conversion_EC2_service.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Unitconversion"
    }
}
}

# 9. Create target server and install agent
resource "aws_instance" "web-server-instance-1" {
   ami               = "ami-0d5eff06f840b45e9"
   instance_type     = "t2.micro"
   availability_zone = "us-east-1a"
   key_name          = "main-key"
   iam_instance_profile = "${aws_iam_instance_profile.EC2_AWSCodeDeployProfile.name}"
   
   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.web-server-nic-1.id
   }
   user_data = "${data.template_file.user_data.rendered}"   
   tags = {
     Name = "Unitconversion"
   }
   depends_on = [aws_eip.one]
 }
 
 output "server_public_ip" {
   value = aws_eip.one.public_ip
}
