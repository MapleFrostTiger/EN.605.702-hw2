provider "aws" {
  region = "us-east-1"
}

# CodeBuild Project for building and deploying to EKS
resource "aws_codebuild_project" "order_processing_project" {
  name          = "OrderProcessingBuild"
  service_role  = aws_iam_role.codebuild_role.arn
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true  # Required for Docker builds
    environment_variables = [
      {
        name  = "CLUSTER_NAME"
        value = "order-processing-cluster"
      },
      {
        name  = "REGION"
        value = "us-east-1"
      }
    ]
  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/MapleFrostTiger/EN.605.702-hw2"
    git_clone_depth = 1
  }
  artifacts {
    type = "CODEPIPELINE"
  }
  cache {
    type     = "LOCAL"
    modes    = ["LOCAL_DOCKER_LAYER_CACHE"]
  }
  buildspec = file("${path.module}/../scripts/buildspec.yaml")
}

# CodePipeline definition
resource "aws_codepipeline" "order_processing_pipeline" {
  name     = "OrderProcessingPipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "MapleFrostTiger"
        Repo       = "your-repo-name"
        Branch     = "main"
        OAuthToken = var.github_token
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

      configuration = {
        ProjectName = aws_codebuild_project.order_processing_project.name
      }
    }
  }
}
