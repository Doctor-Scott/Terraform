provider "aws" {
  region  = "eu-west-2"
  profile = "estio"
}

module "vpc" {
  source        = "./modules/vpc"
  vpc_name      = "estioVPC"
  vpc_cidr      = "10.0.0.0/16"
  public1_cidr  = "10.0.1.0/24"
  public2_cidr  = "10.0.2.0/24"
  private1_cidr = "10.0.3.0/24"
  private2_cidr = "10.0.4.0/24"
  private1_az   = data.aws_availability_zones.available.names[0]
  private2_az   = data.aws_availability_zones.available.names[1]
  public1_az    = data.aws_availability_zones.available.names[0]
  public2_az    = data.aws_availability_zones.available.names[1]

}
variable "dbPassword" {
  type = string
}

module "mysqlDB" {
  source = "./modules/db"

  vpc_id             = module.vpc.vpc_id
  subnet_private1_id = module.vpc.subnet_private1_id
  subnet_private2_id = module.vpc.subnet_private2_id
  subnet_public1_id  = module.vpc.subnet_public1_id
  subnet_public2_id  = module.vpc.subnet_public2_id
  publicIP           = chomp(data.http.checkIp.body)
  dbPassword         = var.dbPassword
}

/* module "ec2" {
  source     = "./modules/ec2"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_public1_id
  igw_id     = module.vpc.igw_id
  private_ip = "10.0.1.29"

} */

data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "checkIp" {
  url = "http://icanhazip.com/"
}

output "rds_endpoint" {
  value = module.mysqlDB.rds_endpoint
}
/* output "webserverPublicIp" {
  value = module.ec2.webserverPublicIp
} */

/* output "ansiblePublicIP" {
  value = module.ec2.ansiblePublicIP
}

output "dockerPublicIP" {
  value = module.ec2.dockerPublicIP
} */