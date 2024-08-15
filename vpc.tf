# Hub VPC
module "hub_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "Hub-VPC"
  cidr = var.hub_vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.hub_public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# Prod VPC
module "prod_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "Prod-VPC"
  cidr = var.prod_vpc_cidr

  azs              = var.availability_zones
  private_subnets  = var.prod_private_subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
