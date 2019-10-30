terraform {
 backend "gcs" {
   bucket = "remote-state-bucket-bd1eeb5c-48f9-99f0-80b9-0fb2c5ce3edf"
   prefix = "infrastructure/environments/dev/webapp-core"
  }
}