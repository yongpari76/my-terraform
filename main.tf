provider "aws" {
  region = "ap-northeast-2"
}

### vpc start ###

resource "aws_vpc" "test_vpc" {
  cidr_block  = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "test-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "test-pub_2a" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pub-2a"
  }
}

resource "aws_subnet" "test-pub_2b" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pub-2b"
  }
}

resource "aws_subnet" "test-pub_2c" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pub-2c"
  }
}

resource "aws_subnet" "test-pub_2d" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.48.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pub-2d"
  }
}

resource "aws_subnet" "test-pvt_2a" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.64.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pvt-2a"
  }
}

resource "aws_subnet" "test-pvt_2b" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.80.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pvt-2b"
  }
}

resource "aws_subnet" "test-pvt_2c" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.96.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pvt-2c"
  }
}

resource "aws_subnet" "test-pvt_2d" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.112.0/20"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pvt-2d"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test-igw"
  }
}

resource "aws_route_table" "test_pub_rtb" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }
  tags = {
    Name = "test-pub-rtb"
  }
}

resource "aws_route_table" "test_pvt_rtb" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test-pvt-rtb"
  }
}

resource "aws_route_table_association" "test-pub_2a_association" {
  subnet_id = aws_subnet.test-pub_2a.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pub_2b_association" {
  subnet_id = aws_subnet.test-pub_2b.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pub_2c_association" {
  subnet_id = aws_subnet.test-pub_2c.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pub_2d_association" {
  subnet_id = aws_subnet.test-pub_2d.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pvt_2a_association" {
  subnet_id = aws_subnet.test-pvt_2a.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2b_association" {
  subnet_id = aws_subnet.test-pvt_2b.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2c_association" {
  subnet_id = aws_subnet.test-pvt_2c.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2d_association" {
  subnet_id = aws_subnet.test-pvt_2d.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

### vpc end ###

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "test-sg-alb"
}

resource "aws_security_group" "test_web_sg_alb" {
  name   = var.security_group_name
#  vpc_id = data.aws_vpc.test_vpc.id
  vpc_id = aws_vpc.test_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "test-sg-alb"
  }
}

resource "aws_lb" "frontend" {
  name               = "alb-example"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_web_sg_alb.id]
  subnets            = [
    aws_subnet.test-pub_2a.id,
    aws_subnet.test-pub_2c.id
  ]

  tags = {
    Name = "test-alb"
  }

  lifecycle { create_before_destroy = true }
}


resource "aws_instance" "alb_vm_01" {
  ami                    = "ami-035da6a0773842f64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test-pub_2a.id
  vpc_security_group_ids = [aws_security_group.test_web_sg_alb.id]
  key_name  = "aws-hanait-key-20240115"
  user_data = <<-EOF
              #! /bin/bash
              yum install -y httpd
              systemctl enable --now httpd
              echo "Hello, Terraform01" > /var/www/html/index.html
              EOF

  tags = {
    Name = "ALB01"
  }
}

resource "aws_instance" "alb_vm_02" {
  ami                    = "ami-035da6a0773842f64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test-pub_2c.id
  vpc_security_group_ids = [aws_security_group.test_web_sg_alb.id]
  key_name  = "aws-hanait-key-20240115"
  user_data = <<-EOF
              #! /bin/bash
              yum install -y httpd
              systemctl enable --now httpd
              echo "Hello, Terraform02" > /var/www/html/index.html
              EOF

  tags = {
    Name = "ALB02"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test_vpc.id

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_alb_target_group_attachment" "tgattachment01" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.alb_vm_01.id
  port             = 80
}
resource "aws_alb_target_group_attachment" "tgattachment02" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.alb_vm_02.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.frontend.dns_name
}

