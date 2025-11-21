############################
# VPC
############################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

############################
# ECR
############################
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  version = "1.0.1"

  repository_name = "${var.project}-repo"
}

############################
# ECS Cluster
############################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.2.0"

  cluster_name = "${var.project}-cluster"
}

############################
# ALB
############################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.0.0"

  name               = "${var.project}-alb"
  load_balancer_type = "application"

  subnets         = module.vpc.public_subnets
  security_groups = []

  target_groups = {
    app = {
      port     = 80
      protocol = "HTTP"
      target_type = "ip"
      health_check = {
        path = "/"
      }
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type = "forward"
        target_group_key = "app"
      }
    }
  }
}

############################
# ECS Fargate Service
############################
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  name        = "${var.project}-service"
  cluster_arn = module.ecs.cluster_arn

  cpu    = 256
  memory = 512

  desired_count = 1
  launch_type   = "FARGATE"

  subnet_ids = module.vpc.private_subnets

  container_definitions = [{
    name      = "app"
    image     = module.ecr.repository_url
    cpu       = 256
    memory    = 512
    essential = true
    port_mappings = [{
      containerPort = 80
    }]
  }]

  load_balancers = [{
    target_group_arn = module.alb.target_groups["app"].arn
    container_name   = "app"
    container_port   = 80
  }]
}

############################
# IAM Role for CodeBuild
############################
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "logs:*",
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

############################
# CodeBuild
############################
resource "aws_codebuild_project" "build" {
  name         = "${var.project}-build"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "ECR_REPO"
      value = module.ecr.repository_url
    }
  }
}

############################
# CodePipeline IAM Role
############################
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "pipeline_policy" {
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*", "codebuild:*", "iam:PassRole"]
      Resource = "*"
    }]
  })
}

############################
# S3 Bucket for Pipeline
############################
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.project}-pipeline-artifacts"
}

############################
# CodePipeline
############################
resource "aws_codepipeline" "pipeline" {
  name     = "${var.project}-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
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
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
}
