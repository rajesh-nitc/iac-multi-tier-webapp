provider "aws" {
  region = "us-east-2"
  # access_key = "AKIA4MLVRMNDEJUXETHD"
  # secret_key = "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"
  version = "~> 2.0"
}

# resource "random_uuid" "test" {}

# resource "google_storage_bucket" "remote_state_bucket" {
#   name     = "remote-state-bucket-${random_uuid.test.result}"
#   location = "ASIA"
#   versioning {
#       enabled = true
#   }
# }

resource "aws_codecommit_repository" "repo_client" {
  repository_name = "${var.repo_client}"
}

resource "aws_codecommit_repository" "repo_infra" {
  repository_name = "${var.repo_infra}"
}

resource "aws_codecommit_repository" "repo_server" {
  repository_name = "${var.repo_server}"
}