provider "google" {
  version = "~> 2.1"
  region  = "${var.region}"
  project = "${var.project_id}"
  zone    = "${var.region}-a"
}

resource "random_uuid" "test" {}

resource "google_storage_bucket" "remote_state_bucket" {
  name     = "remote-state-bucket-${random_uuid.test.result}"
  location = "ASIA"
  versioning {
      enabled = true
  }
}

resource "google_sourcerepo_repository" "repo_client" {
  name = "${var.repo_client}"
}

resource "google_sourcerepo_repository" "repo_server" {
  name = "${var.repo_server}"
}

resource "google_sourcerepo_repository" "repo_infra" {
  name = "${var.repo_infra}"
}