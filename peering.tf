# VPC Peering
resource "aws_vpc_peering_connection" "hub_prod" {
  vpc_id      = module.hub_vpc.vpc_id
  peer_vpc_id = module.prod_vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "Hub-Prod-Peering"
  }
}

# Route tables for Hub VPC to Prod VPC
resource "aws_route" "hub_to_prod" {
  route_table_id            = element(module.hub_vpc.public_route_table_ids, 0)
  destination_cidr_block    = var.prod_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_prod.id
}

# Route tables for Prod VPC to Hub VPC
resource "aws_route" "prod_to_hub" {
  route_table_id            = element(module.prod_vpc.private_route_table_ids, 0)
  destination_cidr_block    = var.hub_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_prod.id
}
