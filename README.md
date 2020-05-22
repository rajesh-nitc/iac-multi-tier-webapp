## iac

### webapp
3 tier application with a frontend in Angular, served by nginx webserver, backend in nodejs and a mysql database

### folder structure
There are four mutually exclusive projects in this repo:
1. infra-ec2
2. infra-gce
3. infra-gke
4. infra-eks
### deploy cloud infrastructure and webapp on ec2
#### deploy three ```aws_codecommit_repository```, one to store client code, one for server code and one to store infra code
```
cd infra-ec2/environments/dev/webapp-init
terraform init
terraform plan
terraform apply --auto-approve
```
push client code, server, infra-ec2 code in their respective repos
#### deploy the infra
```
cd infra-ec2/environments/dev/webapp-core
terraform init
terraform plan
terraform apply --auto-approve
```
*This will deploy an application load balancer, autoscaling group for the angular application, internal application load balancer, autoscaling group for the nodejs application and a private rds mysql database*

### deploy cloud infrastructure and webapp on gce
#### deploy three ```google_sourcerepo_repository```, one to store client code, one for server code and one to store infra code and a ```google_storage_bucket``` to store terraform state
```
cd infra-gce/environments/dev/webapp-init
terraform init
terraform plan
terraform apply --auto-approve
```
push client code, server, infra-gce code in their respective repos
#### deploy the infra and continous deployment (cd) setup
```
cd infra-gce/environments/dev/webapp-core
terraform init
terraform plan
terraform apply --auto-approve
```
*This will deploy a global load balancer, mig for the angular application, internal load balancer, mig for the nodejs application and a private cloudsql database*

AND on the cd side, the idea is:
Push in a repo will send a message to a pubsub topic and cloud function will subscribe to that message and call the google rest api for mig to recreate the instances!

*On the cd side, This will deploy google_pubsub_topic, google_storage_bucket_object, google_storage_bucket, google_cloudfunctions_function*

### deploy cloud infrastructure and webapp on gke
#### deploy two ```google_sourcerepo_repository```, one to store client code, one for server code and a ```google_cloudbuild_trigger``` on each repo for the cd
```
cd infra-gke/environments/dev/webapp-init
terraform init
terraform plan
terraform apply --auto-approve
```
push client code, server code in their respective repos
#### 1. deploy the kubernetes cluster
**Look for this comment "After creating the cluster" in ```infra-gke/environments/dev/webapp-core/main.tf``` and comment out everything after this comment**
```
cd infra-gke/environments/dev/webapp-core
terraform init
terraform plan
terraform apply --auto-approve
```
*This will deploy the kubernetes cluster*
#### 2. deploy webapp on the kubernetes cluster
Now uncomment everything after this comment "After creating the cluster" in ```infra-gke/environments/dev/webapp-core/main.tf``` and comment out part above about creating the cluster
```
cd infra-gke/environments/dev/webapp-core
terraform init
terraform plan
terraform apply --auto-approve
```
The similar approach is used for ```infra-eks``` project
