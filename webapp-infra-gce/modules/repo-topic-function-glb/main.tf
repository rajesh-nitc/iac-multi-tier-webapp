resource "google_pubsub_topic" "example" {
  name = "fe-topic01"

  provisioner "local-exec" {
    command = "gcloud source repos update $REPO --add-topic=$TOPIC"

    environment = {
      REPO = "${var.repo_client}"
      TOPIC = "fe-topic01"
    }
  }
}

data "archive_file" "zip" {
 type        = "zip"
 source_dir  = "${path.module}/index"
 output_path = "${path.module}/index.zip"
}

resource "random_id" "default" {
  byte_length = 4
  prefix      = "fe-function-"
}

resource "google_storage_bucket" "function_bucket" {
  name     = "${random_id.default.hex}"
  force_destroy = true
  location = "ASIA"
  versioning {
      enabled = true
  }
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = "${google_storage_bucket.function_bucket.name}"
  source = "${path.module}/index.zip"
}

resource "google_cloudfunctions_function" "function" {
  name                = "${var.cfunction_name}"
  project             = "tf-first-project"
  region              = "us-central1"
  description         = "My function"
  runtime             = "${var.cfunction_runtime}"
  available_memory_mb = 128
  # trigger_http        = true
  # trigger_topic = "${google_pubsub_topic.example.name}"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "${google_pubsub_topic.example.name}"
  }
  entry_point = "${var.centry_point}"
  source_archive_bucket = "${google_storage_bucket.function_bucket.name}"
  source_archive_object = "${google_storage_bucket_object.archive.name}"
}