provider "aws" {
  region = "ap-northeast-1"
}

# 1. 常に最新の Amazon Linux 2023 を探す
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# 2. ネットワーク構築 (VPC + Subnet)
resource "aws_vpc" "my_web_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "my-web-vpc" }
}

resource "aws_subnet" "my_web_subnet" {
  vpc_id                  = aws_vpc.my_web_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "my-web-subnet" }
}

# 3. インターネット接続設定 (IGW + Route Table)
resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.my_web_vpc.id
}

resource "aws_route_table" "my_web_rt" {
  vpc_id = aws_vpc.my_web_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
}

resource "aws_route_table_association" "my_web_assoc" {
  subnet_id      = aws_subnet.my_web_subnet.id
  route_table_id = aws_route_table.my_web_rt.id
}

# 4. セキュリティグループ (HTTPアクセス許可)
resource "aws_security_group" "web_server_sg" {
  name   = "web-server-sg"
  vpc_id = aws_vpc.my_web_vpc.id

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

# 5. Webサーバー構築 (EC2)
resource "aws_instance" "my_web_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_web_subnet.id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform Web Server!</h1>" > /var/www/html/index.html
              EOF

  tags = { Name = "my-web-server" }
}