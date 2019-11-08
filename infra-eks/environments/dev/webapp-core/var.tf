variable "region" {}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::851186901830:role/codebuild-kubectl-role"
      username = "build"
      groups   = ["system:masters"]
    },
  ]
}

variable "CONTAINER_IMAGE_NODE" {}
variable "app_label_nodejs" {}
variable "CONTAINER_IMAGE_NGINX" {}
variable "app_label_nginx" {}