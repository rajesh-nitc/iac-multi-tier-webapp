to do: ssl support for lb_global

Manual steps:

Generate a kubeconfig file:
gcloud beta container clusters get-credentials my-gke-cluster --region asia-south1 --project tf-first-project

Copy the cloudbuild-delivery.yaml files to respective candidate branches: