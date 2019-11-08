# export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/tf-sa.json
# set HTTPS_PROXY=http://1554356:Passwd%40123456@proxy.tcs.com:8080
# set GOOGLE_APPLICATION_CREDENTIALS=C:\MY_DATA\test\tf-sa.json
# ENV="dev"
region = "asia-south1"
project_id = "tf-first-project"

# repo & build trigger
# branch_name = "master"
# repo_name = "nodeapp-repo"
# dir = "application/environments/dev/components/web-server"
# filename = "application/environments/dev/components/web-server/cloudbuild.yaml"

repo_client="webapp-client"
repo_server="webapp-server"
repo_env="env"
repo_kube="kube-infra"