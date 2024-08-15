# Security Groups for Hub VPC
resource "aws_security_group" "hub_security_group" {
  name   = "hub-security-group"
  vpc_id = module.hub_vpc.vpc_id

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
    Name = "Hub-Security-Group"
  }
}

# Security Groups for Prod VPC allowing ingress from Hub VPC's public LB subnet
resource "aws_security_group" "prod_security_group" {
  name   = "prod-security-group"
  vpc_id = module.prod_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [element(module.hub_vpc.public_subnets, 0)]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [element(module.hub_vpc.public_subnets, 0)]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-Security-Group"
  }
}

# Additional Security Group for SSH allowing ingress from Hub-admin-public-SN
resource "aws_security_group" "hub_admin_sg" {
  name   = "hub-admin-sg"
  vpc_id = module.hub_vpc.vpc_id

  ingress {
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
    Name = "Hub-Admin-SG"
  }
}

resource "aws_security_group" "prod_private_sg" {
  name   = "prod-private-sg"
  vpc_id = module.prod_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.hub_admin_sg.cidr_blocks]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [element(module.hub_vpc.public_subnets, 0)]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [element(module.hub_vpc.public_subnets, 0)]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-Private-SG"
  }
}
