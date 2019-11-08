# output "remote_state_bucket" {
#   value = "${google_storage_bucket.remote_state_bucket.name}"
# }
# output "repo_name" {
#   value = "${module.repo_build_trigger.repo_name}"
# }

output "project_number" {
  value = "${data.google_project.project.number}"
} 