############################################################
# VPC MODULE
############################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-${terraform.workspace}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = var.project_name
  }
}

############################################################
# ECR REPOSITORY
############################################################
resource "aws_ecr_repository" "app" {
  name = "${var.project_name}-${terraform.workspace}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

############################################################
# ECS CLUSTER
############################################################
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster-${terraform.workspace}"
}

############################################################
# SECURITY GROUPS
############################################################
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg-${terraform.workspace}"
  description = "Allow inbound HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name   = "${var.project_name}-ecs-sg-${terraform.workspace}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################################
# LOAD BALANCER
############################################################
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb-${terraform.workspace}"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

############################################################
# TARGET GROUP (Corrected)
############################################################
resource "aws_lb_target_group" "tg" {
  name        = "${var.project_name}-tg-${terraform.workspace}"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

############################################################
# LISTENER
############################################################
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  depends_on = [aws_lb_target_group.tg]
}

############################################################
# ECS TASK ROLE
############################################################
resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-task-role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################################################
# EXECUTION ROLE FOR ECS FARGATE
############################################################
data "aws_iam_policy_document" "execution_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.project_name}-execution-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

############################################################
# TASK DEFINITION
############################################################
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project_name}-task-${terraform.workspace}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)

  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${aws_ecr_repository.app.repository_url}:latest"
      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]
      essential = true
    }
  ])
}

############################################################
# ECS FARGATE SERVICE
############################################################
resource "aws_ecs_service" "service" {
  name            = "${var.project_name}-svc-${terraform.workspace}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_lb_listener.listener
  ]
}
