provider "aws" {
  region     = "us-east-2"
  access_key = "AKIA4MLVRMNDBBW4BTMF"
  secret_key = "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"
  version    = "~> 2.0"
}
# resource "aws_codecommit_repository" "repo_client" {
#   repository_name = "${var.repo_client}"
# }

# resource "aws_codecommit_repository" "repo_infra" {
#   repository_name = "${var.repo_infra}"
# }

# resource "aws_codecommit_repository" "repo_server" {
#   repository_name = "${var.repo_server}"
# }
resource "aws_ecr_repository" "ecr_nodejs" {
  name                 = "mynodejs"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_nginx" {
  name                 = "mynginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-artifact-store-1554356"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "pipeline-test-role"
  assume_role_policy = templatefile("${path.module}/iam/codepipeline-assume-role.tmpl", {})
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = templatefile("${path.module}/iam/codepipeline.tmpl", {})
}

resource "aws_iam_role" "codebuild_role" {
  name               = "build-test-role2"
  assume_role_policy = templatefile("${path.module}/iam/codebuild-assume-role.tmpl", {})
}

resource "aws_iam_role_policy" "example" {
  role   = "${aws_iam_role.codebuild_role.name}"
  policy = templatefile("${path.module}/iam/codebuild.tmpl", {})
}

resource "aws_codebuild_project" "nodejs_build" {
  name          = "my-nodejs_build"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "tf-code-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "${var.repo_server}"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.nodejs_build.name}"
      }
    }
  }
}

resource "aws_iam_role" "codebuild_kubectl_assume_role" {
  name               = "codebuild-kubectl-role"
  assume_role_policy = templatefile("${path.module}/iam/codebuild-kubectl-assume-role.tmpl", {})
}

resource "aws_iam_role_policy" "codebuild_kubectl_attach_policy" {
  name   = "codebuild-kubectl-policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = templatefile("${path.module}/iam/codebuild-kubectl.tmpl", {})
}

# nginx codebuild and codepipeline
resource "aws_codebuild_project" "nginx_build" {
  name          = "my-nginx_build"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_codepipeline" "codepipeline-nginx" {
  name     = "tf-code-pipeline-nginx"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "${var.repo_client}"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.nginx_build.name}"
      }
    }
  }
}