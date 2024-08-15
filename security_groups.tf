# Security Groups for Hub VPC
module "hub_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80-443"
  version = "4.5.0"

  name   = "hub-security-group"
  vpc_id = module.hub_vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = var.prod_private_subnets
  egress_rules        = ["http-80-tcp", "https-443-tcp"]
}

# Security Groups for Prod VPC allowing ingress from Hub VPC's public LB subnet
module "prod_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80-443"
  version = "4.5.0"

  name   = "prod-security-group"
  vpc_id = module.prod_vpc.vpc_id

  ingress_cidr_blocks = [module.hub_vpc.public_subnets[0]] # Allow ingress from Hub-prod-public-LB-SN
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["http-80-tcp", "https-443-tcp"]
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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.prod_private_subnets
  }

  tags = {
    Name = "Hub-admin-public-SG"
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
    cidr_blocks = [module.hub_vpc.public_subnets[0]]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.hub_vpc.public_subnets[0]]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-private-SG"
  }
}
