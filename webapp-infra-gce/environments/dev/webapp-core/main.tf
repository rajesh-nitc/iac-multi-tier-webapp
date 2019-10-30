provider "google" {
  version = "~> 2.1"
  region  = "${var.region}"
  project = "${var.project_id}"
  zone    = "${var.region}-a"
}

provider "google-beta" {
  version = "~> 2.1"
  region  = "${var.region}"
  project = "${var.project_id}"
  zone    = "${var.region}-a"
}

module "lb_global" {
  source       = "../../../modules/lb-global"
  project_id   = "${var.project_id}"
  network_name = "${var.network_name}"
  region       = "${var.region}"
  repo_client    = "${var.repo_client}"
}

module "lb_internal" {
  source         = "../../../modules/lb-internal"
  project_id     = "${var.project_id}"
  network_name   = "${module.lb_global.network_name}"
  subnet_name = "${module.lb_global.subnet_name}"
  region         = "${var.region}"
  repo_server      = "${var.repo_server}"

  database_host     = "${module.private_cloud_sql.database_private_ip}"
  database_name     = "${module.private_cloud_sql.database_name}"
  database_user     = "${module.private_cloud_sql.database_user}"
  database_password = "${module.private_cloud_sql.database_password}"
}

module "lb_global_function" {
  source           = "../../../modules/repo-topic-function-glb"
  cfunction_name    = "${var.cfunction_name}"
  cfunction_runtime = "${var.cfunction_runtime}"
  centry_point      = "${var.centry_point}"
  repo_client    = "${var.repo_client}"
}

module "lb_internal_function" {
  source           = "../../../modules/repo-topic-function"
  sfunction_name    = "${var.sfunction_name}"
  sfunction_runtime = "${var.sfunction_runtime}"
  sentry_point      = "${var.sentry_point}"
  repo_server      = "${var.repo_server}"
}

module "private_cloud_sql" {
  source           = "../../../modules/private-cloud-sql"
  network_name    = "${module.lb_global.network_self_link}"
  region = "${var.region}"
}