provider "aws" {
  region  = "eu-west-2"
  profile = "estio"
}

module "vpc" {
  source        = "./modules/vpc"
  vpc_name      = "db-sample"
  vpc_cidr      = "10.0.0.0/16"
  public_cidr   = "10.0.1.0/24"
  private1_cidr = "10.0.2.0/24"
  private2_cidr = "10.0.3.0/24"
  private1_az   = data.aws_availability_zones.available.names[0]
  private2_az   = data.aws_availability_zones.available.names[1]
  public_az     = data.aws_availability_zones.available.names[0]

}

/* module "mysqlDB" {
  source = "./modules/db"

  vpc_id          = module.vpc.vpc_id
  subnet_private1_id = module.vpc.subnet_private1_id
  subnet_private2_id = module.vpc.subnet_private2_id
} */

module "ec2" {
  source     = "./modules/ec2"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_public_id
  igw_id     = module.vpc.igw_id
  private_ip = "10.0.1.29"

}

data "aws_availability_zones" "available" {
  state = "available"
}

output "ansiblePublicIP" {
  value = module.ec2.ansiblePublicIP
}

output "dockerPublicIP" {
  value = module.ec2.dockerPublicIP
}