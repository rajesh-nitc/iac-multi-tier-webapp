provider "aws" {
  region     = "us-east-2"
  access_key = "AKIA4MLVRMNDBBW4BTMF"
  secret_key = "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"
  version    = "~> 2.0"
}
data "aws_availability_zones" "available" {
}
resource "random_string" "suffix" {
  length  = 8
  special = false
}
locals {
  cluster_name = "test-eks1-${random_string.suffix.result}"
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = module.vpc.private_subnets
  vpc_id       = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "t2.small"
      asg_max_size  = 5
      tags = [{
        key                 = "foo"
        value               = "bar"
        propagate_at_launch = true
      }]
    }
  ]

  map_roles = var.map_roles

  tags = {
    environment = "test"
  }

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "test-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# :::::After creating cluster:::::

 provider "kubernetes" {
 }

 module "lb_global" {
   source            = "../../../modules/lb-global"
    CONTAINER_IMAGE_NGINX = "${var.CONTAINER_IMAGE_NGINX}"
   app_label_nginx   = "${var.app_label_nginx}"
   create_dependency = "${module.lb_internal.nodejs_service}"
 }

 module "lb_internal" {
   source               = "../../../modules/lb-internal"
   CONTAINER_IMAGE_NODE = "${var.CONTAINER_IMAGE_NODE}"
   app_label_nodejs     = var.app_label_nodejs
   database_host        = "${module.private_cloud_sql.database_private_ip}"
   database_name        = "${module.private_cloud_sql.database_name}"
   database_user        = "${module.private_cloud_sql.database_user}"
   database_password    = "${module.private_cloud_sql.database_password}"
 }

module "private_cloud_sql" {
  source     = "../../../modules/private-cloud-sql"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}
