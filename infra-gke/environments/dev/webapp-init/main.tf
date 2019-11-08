provider "google" {
  version = "~> 2.1"
  region  = "${var.region}"
  project = "${var.project_id}"
  zone    = "${var.region}-a"
}

# uncomment if repos don't exist
# resource "google_sourcerepo_repository" "repo_server" {
#   name = "${var.repo_server}"
# }
# resource "google_sourcerepo_repository" "repo_client" {
#   name = "${var.repo_client}"
# }

resource "google_sourcerepo_repository" "repo_env" {
  name = "${var.repo_env}"
}

resource "google_sourcerepo_repository" "repo_kube" {
  name = "${var.repo_kube}"
}

data "google_project" "project" {}

# Grant the Source Repository Writer IAM role to the Cloud Build service account for the env repository.
resource "google_sourcerepo_repository_iam_binding" "editor" {
    project = "${var.project_id}"
    repository = "${google_sourcerepo_repository.repo_env.name}"
    role = "roles/source.writer"
    members = [
        "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    ]
}

resource "google_cloudbuild_trigger" "server_build" {
  trigger_template {
    branch_name = "master"
    # repo_name   = "${google_sourcerepo_repository.repo_server.name}"
    repo_name   = "${var.repo_server}"
  }

  filename = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "candidate_server_delivery" {
  trigger_template {
    branch_name = "candidate-server"
    # repo_name   = "${google_sourcerepo_repository.repo_server.name}"
    repo_name   = "${var.repo_env}"
  }

  filename = "cloudbuild-delivery-server.yaml"
}

resource "google_cloudbuild_trigger" "client_build" {
  trigger_template {
    branch_name = "master"
    # repo_name   = "${google_sourcerepo_repository.repo_client.name}"
    repo_name   = "${var.repo_client}"
  }

  filename = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "candidate_client_delivery" {
  trigger_template {
    branch_name = "candidate-client"
    # repo_name   = "${google_sourcerepo_repository.repo_server.name}"
    repo_name   = "${var.repo_env}"
  }

  filename = "cloudbuild-delivery-client.yaml"
}

# To deploy the app in your Kubernetes cluster, Cloud Build needs the Kubernetes Engine Developer IAM Role.
resource "google_project_iam_binding" "project" {
  project = "${var.project_id}"
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
  ]
}