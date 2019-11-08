provider "aws" {
  region = "us-east-2"
  # access_key = "AKIA4MLVRMNDEJUXETHD"
  # secret_key = "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"
  version = "~> 2.0"
}

module "lb_global" {
  source       = "../../../modules/lb-global"
  region       = "${var.region}"
  repo_client    = "${var.repo_client}"
}

module "lb_internal" {
   source         = "../../../modules/lb-internal"
   region       = "${var.region}"
  repo_server    = "${var.repo_server}"
  vpc_id    = "${module.lb_global.vpc_id}"
  subnet1    = "${module.lb_global.subnet1}"
  subnet2    = "${module.lb_global.subnet2}"

  database_host     = "${module.private_cloud_sql.database_private_ip}"
  database_name     = "${module.private_cloud_sql.database_name}"
  database_user     = "${module.private_cloud_sql.database_user}"
  database_password = "${module.private_cloud_sql.database_password}"

 }

# module "lb_global_function" {
#   source           = "../../../modules/repo-topic-function-glb"
#   cfunction_name    = "${var.cfunction_name}"
#   cfunction_runtime = "${var.cfunction_runtime}"
#   centry_point      = "${var.centry_point}"
#   repo_client    = "${var.repo_client}"
# }

# module "lb_internal_function" {
#   source           = "../../../modules/repo-topic-function"
#   sfunction_name    = "${var.sfunction_name}"
#   sfunction_runtime = "${var.sfunction_runtime}"
#   sentry_point      = "${var.sentry_point}"
#   repo_server      = "${var.repo_server}"
# }

module "private_cloud_sql" {
   source           = "../../../modules/private-cloud-sql"
   vpc_id    = "${module.lb_global.vpc_id}"
  subnet1    = "${module.lb_global.subnet1}"
  subnet2    = "${module.lb_global.subnet2}"
 }