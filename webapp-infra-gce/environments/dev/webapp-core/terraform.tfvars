# client

region = "asia-south1"
project_id = "tf-first-project"
network_name = "vpc-dev"
repo_client = "webapp-client"

# function-topic
cfunction_name = "fe-function"
cfunction_runtime = "nodejs8"
centry_point = "helloPubSub"

# server

repo_server = "webapp-server"

# function-topic
sfunction_name = "be-function"
sfunction_runtime = "nodejs8"
sentry_point = "helloPubSub"