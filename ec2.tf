# EC2 Instances
module "jump_server" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "3.1.0"

  name           = "jump-server"
  ami            = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name 

  vpc_security_group_ids = [module.hub_security_group.this_security_group_id, aws_security_group.hub_admin_sg.id]
  subnet_id              = element(module.hub_vpc.public_subnets, 1)

  tags = {
    Name = "jump-server"
  }
}

module "bastion_server" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "3.1.0"

  name           = "bastion-server"
  ami            = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name 

  vpc_security_group_ids = [aws_security_group.prod_private_sg.id, module.prod_security_group.this_security_group_id]
  subnet_id              = element(module.prod_vpc.private_subnets, 0)

  tags = {
    Name = "bastion-server"
  }
}
