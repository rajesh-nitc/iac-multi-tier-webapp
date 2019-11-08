resource "google_sourcerepo_repository" "nodeapp-repo" {
  name = "${var.repo_name}"
}

resource "google_cloudbuild_trigger" "nodeapp-build" {
  trigger_template {
    branch_name = "${var.branch_name}"
    dir = "${var.dir}"
    repo_name   = "${google_sourcerepo_repository.nodeapp-repo.name}"
  }

  filename = "${var.filename}"
}