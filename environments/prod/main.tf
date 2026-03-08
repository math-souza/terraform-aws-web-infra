# Configuracao do AWS Provider
provider "aws" {
  region = var.region
}

module "network" {
  source = "../../modules/network"
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.network.vpc_id
}

module "iam" {
  source = "../../modules/iam"
}

module "compute" {
  source = "../../modules/compute"

  private_subnet_a = module.network.private_subnets[0]
  private_subnet_b = module.network.private_subnets[1]

  ec2_sg = module.security.ec2_sg

  instance_profile = module.iam.instance_profile

  ami = "ami-0c1fe732b5494dc14"
  instance_type = "t2.micro"

  bucket_name = "website-project-matheus"
}

module "alb" {
  source = "../../modules/alb"

  vpc_id = module.network.vpc_id

  public_subnets = module.network.public_subnets

  alb_sg = module.security.alb_sg

  instances = module.compute.instance_ids
}

module "endpoint" {
  source = "../../modules/endpoints"

  vpc_id = module.network.vpc_id
  private_route_table_id = module.network.private_route_table_id
}

module "dns" {
  source = "../../modules/dns"

  alb_dns = module.alb.alb_dns
  alb_zone = module.alb.alb_zone
}
