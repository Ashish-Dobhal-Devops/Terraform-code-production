# Terraform Infrastructure Configuration

## Overview

This project contains Terraform configurations to set up a secure and scalable AWS infrastructure with two VPCs (Hub VPC and Prod VPC) and their respective subnets, security groups, VPC peering, and EC2 instances. 

## Infrastructure Components

1. **Hub VPC**
   - CIDR: `10.0.0.0/16`
   - Subnets:
     - Public Subnet 1: `10.0.1.0/24`
     - Public Subnet 2: `10.0.2.0/24`
   - Security Group:
     - Allows HTTP (port 80) and HTTPS (port 443) inbound traffic from anywhere.
     - Allows outbound traffic to Prod VPC private subnets on HTTP and HTTPS ports.

2. **Prod VPC**
   - CIDR: `10.1.0.0/16`
   - Subnets:
     - Private Subnet 1: `10.1.1.0/24`
     - Private Subnet 2: `10.1.2.0/24`
   - Security Group:
     - Allows HTTP (port 80), HTTPS (port 443), and SSH (port 22) inbound traffic from Hub VPC subnets.
     - Allows outbound traffic to anywhere on HTTP and HTTPS ports.

3. **VPC Peering**
   - Enables communication between Hub VPC and Prod VPC.

4. **EC2 Instances**
   - Jump Server in Hub VPC:
     - Placed in Public Subnet 2.
     - Security group allows SSH (port 22) access from anywhere.
     - Used to SSH into Bastion Server in Prod VPC.
   - Bastion Server in Prod VPC:
     - Placed in Private Subnet 1.
     - Security group allows SSH (port 22) access from Jump Server.
     - Used to connect to the EKS cluster in Prod VPC.

## Network Flow

1. **Internet to Jump Server**
   - Users can SSH into the Jump Server in the Hub VPC from the internet.
   
2. **Jump Server to Bastion Server**
   - From the Jump Server, users can SSH into the Bastion Server in the Prod VPC using the private IP address.

3. **Communication Between VPCs**
   - The VPC peering connection allows the Hub VPC and Prod VPC to communicate.
   - Routes are set up in both VPCs to direct traffic through the VPC peering connection.

## Files

- `main.tf`: Initializes the AWS provider.
- `vpc.tf`: Sets up the VPCs and subnets.
- `peering.tf`: Configures VPC peering and routes.
- `security_groups.tf`: Configures security groups.
- `ec2.tf`: Sets up EC2 instances.
- `variables.tf`: Contains all the variable definitions.
- `outputs.tf`: Defines the outputs for the configuration.

## Usage

1. Initialize Terraform:
   ```sh
   terraform init
   ```

2. Apply the Terraform configuration:
   ```sh
   terraform apply
   ```

3. Retrieve the public IP of the Jump Server:
   ```sh
   terraform output -json | jq -r '.jump_server_public_ip.value'
   ```

4. SSH into the Jump Server:
   ```sh
   ssh -i path/to/private_key.pem ec2-user@<jump_server_public_ip>
   ```

5. Retrieve the private IP of the Bastion Server:
   ```sh
   terraform output -json | jq -r '.bastion_server_private_ip.value'
   ```

6. SSH into the Bastion Server from the Jump Server:
   ```sh
   ssh -i path/to/private_key.pem ec2-user@<bastion_server_private_ip>
   ```

## Conclusion

This Terraform configuration sets up a secure and scalable AWS infrastructure with two VPCs, subnets, security groups, VPC peering, and EC2 instances to facilitate SSH access through a Jump Server and Bastion Server. This setup is ideal for environments that require secure access to internal resources.
