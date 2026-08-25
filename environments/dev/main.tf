provider "aws" {
  region = "us-east-1"
}

module "network" {
  source      = "../../modules/network"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "identity" {
  source = "../../modules/identity"
}

module "kinesis" {
  source             = "../../modules/kinesis"
  environment        = var.environment
  bronze_bucket_name = "bronze-datalake-maxjaida-dev"
}