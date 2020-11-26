terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile                 = var.aws_profile
  region                  = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
}

module "acm" {
  source                  = "../../modules/acm_cert"
  domain_name             = var.domain_name
  # outputs: acm_certificate , domain_name
}

module "rds" {
  source                  = "../../modules/rds_mariadb"
  vpc_id                  = var.aws_vpc
  storage_size            = 20
  dbname                  = var.dbname
  dbuser                  = var.dbuser
  dbpass                  = var.dbpass
  rds_subnet_group        = module.vpc.rds_subnet_group.name

}

module "vpc" {
  source                  = "../../modules/vpc"
  # name                    = "TEST-VPC"
  # environment             = "PROD"
  vpc_id                  = var.aws_vpc
  azs_count               = 3
  cidr_start_index        = 42
  single_nat_gateway      = "true"
}

module "efs" {
  source                  = "../../modules/efs"
  # name                    = "TEST-VPC"
  # environment             = "PROD"
  target_subnets          = module.vpc.private_subnets  
}

module "bastion" {
  source                  = "../../modules/bastion"
  # name                    = "TEST-VPC"
  # environment             = "PROD"
  vpc_id                  = var.aws_vpc
  azs_count               = module.vpc.azs_deployed_qty
  public_subnets          = module.vpc.public_subnets
}

module "lamp" {
  source                  = "../../modules/lamp"
  # name                    = "TEST-VPC"
  # environment             = "PROD"
  vpc_id                  = var.aws_vpc
  azs_count               = module.vpc.azs_deployed_qty
  public_subnets          = module.vpc.public_subnets
  private_subnets         = module.vpc.private_subnets
  allowed_ports           = ["80", "443"]
  ssh_sg_id               = module.bastion.ssh_sg
} 

module "dns" {
  source                  = "../../modules/route53"
  hosted_zone_id          = "Z07126282Q9H80DBN94CL"
  domain_name             = var.domain_name
  alb                     = module.lamp.app_balancer
}

# module.vpc   outputs

# output "azs_deployed_qty" {
#   value = local.azs_number
# }
# output "public_subnets" {
#   value = aws_subnet.subnet_public
# }
# output "private_subnets" {
#   value = aws_subnet.subnet_private
# }
# output "db_subnets" {
#   value = aws_subnet.subnet_db
# }
# output "rds_subnet_group" {
#   value = aws_db_subnet_group.rds_subnet_group
# }